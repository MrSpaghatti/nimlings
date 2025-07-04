import cligen

# Nimlings - A CLI tool for learning Nim
# This is the main entry point for the application.

proc hello*(name: string = "World") =
  ## Prints a greeting message.
  echo "Hello, " & name & "!"

proc version*() =
  ## Shows version information.
  echo "Nimlings Alpha Version 0.1.0"

import osproc # Still needed for validation script execution, consider moving that to sandbox too
import os
import lessons
import state
import strutils
import sandbox # Import the new sandbox module
import times

# Remove local definitions of RunResultFlag and CompileAndRunResult as they come from sandbox
# type RunResultFlag = enum ...
# type CompileAndRunResult = object ...

# Remove local compileAndRun proc, it's now in sandbox.nim
# proc compileAndRun(filePath: string): CompileAndRunResult = ...


proc runExercise*(exerciseNameOrPath: string) =
  ## Compiles and runs the specified exercise using the sandbox module.
  ## If the exercise compiles and runs successfully, it's marked as complete.
  var userState = loadState()
  let allExercises = discoverExercises()

  let exerciseOpt = findExercise(exerciseNameOrPath, allExercises)
  if exerciseOpt.isNone:
    echo "Error: Exercise '", exerciseNameOrPath, "' not found."
    echo "Run `nimlings list` to see available exercises."
    return

  let exercise = exerciseOpt.get
  echo "Running exercise: ", exercise.topic, "/", exercise.name
  echo "File: ", exercise.path
  echo "WARNING: Exercises are run without a secure sandbox. Do not run untrusted exercises." # Add warning
  echo "--------------------------------------------------"

  # Call the sandboxed execution
  var sboxResult = sandbox.executeSandboxed(exercise.path, exercise.path.parentDir)
  var overallSuccess = false
  var validationRunOutput = "" # To store output from validation script or comparison

  if sandbox.CompilationFailed in sboxResult.flags:
    echo "❌ Compilation Failed ❌"
    echo sboxResult.compilationOutput
  elif sandbox.RuntimeFailed in sboxResult.flags:
    echo "💥 Runtime Error 💥"
    echo sboxResult.runtimeOutput # This contains the error message from the exercise
  else: # Compiled and ran without error (according to sandbox), now check validation
    echo "✅ Compiled and Ran Successfully (according to sandbox)."
    echo "--- Output from your program ---"
    echo sboxResult.runtimeOutput
    echo "--- End of Output ---"

    # Normalize outputs for comparison (e.g., CRLF to LF, trim trailing newlines)
    let normalizedRuntimeOutput = sboxResult.runtimeOutput.strip().replace("\r\n", "\n")
    var currentFlags = sboxResult.flags # Copy flags to modify for validation

    if exercise.expectedOutput.isSome:
      let expected = exercise.expectedOutput.get.strip().replace("\r\n", "\n")
      echo "\n🔍 Validating output..."
      if normalizedRuntimeOutput == expected:
        currentFlags = {sandbox.Success}
        validationRunOutput = "Output matches expected output."
        overallSuccess = true
      else:
        currentFlags = {sandbox.ValidationFailed}
        validationRunOutput = "Output does not match expected output.\nExpected:\n---\n" & expected &
                                 "\n---\nGot:\n---\n" & normalizedRuntimeOutput & "\n---"
    elif exercise.validationScript.isSome:
      let scriptName = exercise.validationScript.get
      let scriptPath = exercise.path.parentDir / scriptName
      echo "\n🔍 Running validation script: ", scriptPath
      if fileExists(scriptPath):
        var validatorProc = startProcess("nim", args = ["e", "--hints:off", "--stdout:on", scriptPath],
                                         options = {poUsePath, poStdErrToStdOut, poParentStreams},
                                         workingDir = exercise.path.parentDir)
        try:
          validatorProc.inputStream.write(sboxResult.runtimeOutput)
          validatorProc.inputStream.close()
        except IOError:
          currentFlags = {sandbox.ValidationFailed}
          validationRunOutput = "Failed to pipe output to validation script: " & getCurrentExceptionMsg()
          validatorProc.close()

        if sandbox.ValidationFailed notin currentFlags:
            var validatorOutputLines: seq[string]
            while validatorProc.running:
                if validatorProc.peekExitCode != -1: break
                var line = validatorProc.outputStream.readLine()
                if line.len > 0: validatorOutputLines.add(line)
            validatorProc.close()
            validationRunOutput = validatorOutputLines.join("\n")

            if validatorProc.peekExitCode == 0:
                currentFlags = {sandbox.Success}
                overallSuccess = true
            else:
                currentFlags = {sandbox.ValidationFailed}
      else:
        currentFlags = {sandbox.ValidationFailed}
        validationRunOutput = "Validation script not found: " & scriptPath
    else:
      # No specific validation, successful run from sandbox is enough
      overallSuccess = true
      currentFlags = {sandbox.Success}

    sboxResult.flags = currentFlags # Update sboxResult flags with validation outcome

  echo "--------------------------------------------------"

  if overallSuccess:
    echo "🎉 Exercise completed successfully! 🎉"
    if validationRunOutput.len > 0 : echo "Validation: ", validationRunOutput
    if exercise.path notin userState.completedExercises:
      userState.completedExercises.add(exercise.path)
      userState.points += exercise.pointsValue
      saveState(userState)
      echo "Gained ", exercise.pointsValue, " points! Total points: ", userState.points
      echo "Progress saved."
    else:
      echo "This exercise was already completed. (No points awarded this time)"
  else:
    echo "❌ Exercise failed. Please check the compiler messages above and try again."
    echo "Hint: ", if exercise.hint.len > 0: exercise.hint else: "No hint available for this exercise."


proc hint*(exerciseNameOrPath: string) =
  ## Shows a hint for the specified exercise.
  let allExercises = discoverExercises()
  let exerciseOpt = findExercise(exerciseNameOrPath, allExercises)

  if exerciseOpt.isNone:
    echo "Error: Exercise '", exerciseNameOrPath, "' not found."
    echo "Run `nimlings list` to see available exercises."
    return

  let exercise = exerciseOpt.get
  echo "Hint for ", exercise.topic, "/", exercise.name, ":"
  if exercise.hint.len > 0:
    echo exercise.hint
  else:
    echo "No hint available for this exercise."

proc listExercises*() =
  ## Lists all available exercises and their completion status.
  let userState = loadState()
  let allExercises = discoverExercises()

  if allExercises.len == 0:
    echo "No exercises found. Please make sure the 'exercises' directory is set up correctly."
    return

  echo "Available exercises:"
  echo "Status | Topic          | Name              | Points | Description"
  echo "-------|----------------|-------------------|--------|------------------------------------"

  var currentTopic = ""
  for ex in allExercises:
    if ex.topic != currentTopic:
      if currentTopic != "": # Add a separator line between topics, but not before the first one
        echo "-------|----------------|-------------------|--------|------------------------------------"
      currentTopic = ex.topic

    let status = if ex.path in userState.completedExercises: "[DONE]" else: "[TODO]"
    let topicFormatted = ex.topic.align(14)
    let nameFormatted = ex.name.align(17)
    let pointsFormatted = $ex.pointsValue.align(6) # Convert int to string for align

    echo status, " | ", topicFormatted, " | ", nameFormatted, " | ", pointsFormatted, " | ", ex.description

  echo "---------------------------------------------------------------------------------------------"
  echo "Total Points: ", userState.points
  echo "Run an exercise using: nimlings run <exercise_name_or_path>"
  echo "Get a hint using: nimlings hint <exercise_name_or_path>"
  echo "Check your progress: nimlings status"


when isMainModule:
import times

proc findNextPendingExercise*(allExercises: seq[Exercise], state: UserState): Option[Exercise] =
  for ex in allExercises:
    if ex.path notin state.completedExercises:
      return some(ex)
  return none()

proc watch*(exerciseToWatch: string = "") =
  ## Monitors an exercise file for changes and automatically runs it.
  ## If no exercise is specified, it watches the next pending exercise.
  var userState = loadState()
  let allExercises = discoverExercises()
  var currentExerciseOpt: Option[Exercise]

  if exerciseToWatch.len > 0:
    currentExerciseOpt = findExercise(exerciseToWatch, allExercises)
    if currentExerciseOpt.isNone:
      echo "Error: Specified exercise '", exerciseToWatch, "' not found."
      return
  else:
    currentExerciseOpt = findNextPendingExercise(allExercises, userState)
    if currentExerciseOpt.isNone:
      echo "Congratulations! All exercises completed. Nothing to watch."
      return

  var currentExercise = currentExerciseOpt.get
  echo "Watching exercise: ", currentExercise.topic, "/", currentExercise.name
  echo "Path: ", currentExercise.path
  echo "Press Ctrl+C to stop watching."

  var lastModTime = getLastModificationTime(currentExercise.path)

  # Initial run
  runExercise(currentExercise.path)
  userState = loadState() # Reload state in case runExercise completed it

  try:
    while true:
      sleep(1000) # Check every 1 second
      let modTime = getLastModificationTime(currentExercise.path)
      if modTime > lastModTime:
        echo "\nFile change detected. Re-running exercise..."
        lastModTime = modTime
        runExercise(currentExercise.path)

        # Check if current exercise was completed and suggest next one
        userState = loadState() # Reload state
        if currentExercise.path in userState.completedExercises:
          echo "\n🎉 Great job on completing: ", currentExercise.name, "! 🎉"
          currentExerciseOpt = findNextPendingExercise(allExercises, userState)
          if currentExerciseOpt.isSome:
            currentExercise = currentExerciseOpt.get
            echo "\nNow watching next exercise: ", currentExercise.topic, "/", currentExercise.name
            echo "Path: ", currentExercise.path
            lastModTime = getLastModificationTime(currentExercise.path)
            # Optionally, run the new exercise immediately
            # runExercise(currentExercise.path)
          else:
            echo "✨ You've completed all exercises! ✨"
            break

      # Check if state changed externally (e.g. user ran `run` in another terminal)
      # This is less critical for watch mode but good for robustness
      let freshState = loadState()
      if freshState.completedExercises != userState.completedExercises:
        userState = freshState
        if currentExercise.path in userState.completedExercises:
          echo "\nExercise ", currentExercise.name, " appears to be completed."
          currentExerciseOpt = findNextPendingExercise(allExercises, userState)
          if currentExerciseOpt.isSome:
            currentExercise = currentExerciseOpt.get
            echo "Switching watch to next exercise: ", currentExercise.topic, "/", currentExercise.name
            echo "Path: ", currentExercise.path
            lastModTime = getLastModificationTime(currentExercise.path)
          else:
            echo "All exercises completed!"
            break
  except Interrupt:
    echo "\nStopped watching. Bye!"

proc status*() =
  ## Displays the user's current progress and points.
  let userState = loadState()
  let allExercises = discoverExercises()

  let completedCount = userState.completedExercises.len
  let totalExercises = allExercises.len

  echo "--- Your Nimlings Status ---"
  echo "Total Points: ", userState.points
  echo "Exercises Completed: ", completedCount, "/", totalExercises

  if totalExercises > 0:
    let percentage = (completedCount.toFloat / totalExercises.toFloat * 100.0)
    echo "Progress: ", formatFloat(percentage, ffDecimal, 2), "%"

  if completedCount == totalExercises && totalExercises > 0:
    echo "✨ Congratulations! You have completed all available exercises! ✨"
  elif totalExercises > 0 :
    let nextEx = findNextPendingExercise(allExercises, userState)
    if nextEx.isSome:
      echo "Next up: ", nextEx.get.topic, "/", nextEx.get.name
  else:
    echo "No exercises found. Add some to the 'exercises' directory!"
  echo "---------------------------"


when isMainModule:
import rdstdin

proc runTemporaryNimCode(code: string, tempFileName: string = "nimlings_repl_temp.nim"): sandbox.SandboxedExecutionResult =
  ## Writes the given code to a temporary file and runs it using the sandbox.
  try:
    writeFile(tempFileName, code)
  except IOError:
    var res: sandbox.SandboxedExecutionResult
    res.flags = {sandbox.CompilationFailed} # Use CompilationFailed to indicate setup error
    res.compilationOutput = "Error: Could not write temporary file for REPL."
    return res

  let result = sandbox.executeSandboxed(tempFileName, getCurrentDir()) # Run in current dir

  # temp file cleanup is tricky if sandbox compilation creates more artifacts.
  # For now, simple removal. executeSandboxed already removes its own .exe_temp_sandbox
  if fileExists(tempFileName):
    try:
      removeFile(tempFileName)
    except OSError: # May fail if executable is still somehow locked, though unlikely
      echo "Warning: Could not clean up temporary REPL file: ", tempFileName

  return result

proc shell*() =
  ## Opens a basic interactive Nim shell (REPL).
  ## Type `:quit` or `:exit` to leave the shell.
  echo "Welcome to the Nimlings Interactive Shell (REPL)!"
  echo "Type Nim code directly. Use `:quit` or `:exit` to leave."
  echo "WARNING: Code is run via the sandbox module, which is not yet secure."
  echo "---"

  var currentInput = ""
  while true:
    let prompt = if currentInput.len == 0: "nim> " else: "nim| "
    stdout.write(prompt)
    stdout.flushFile()

    let line =readLine(stdin)

    if line.len == 0 and currentInput.len > 0: # User might press enter to submit multi-line
        # continue, effectively treating blank line as "run current buffer" for multi-line
        # For now, let's require explicit run or treat each line separately unless we add :run
        # For simplicity, let's just execute currentInput if it's not empty.
        # This means multi-line needs to be pasted or handled carefully.
        # A better REPL would parse for complete statements.
        # For this basic version, we'll just execute line by line or accumulated lines if we had a trigger.
        # Let's assume each non-command line is part of a block until an empty line or command.
        # No, simpler: each line is an input, for now. Multi-line via copy-paste.
        # Let's stick to: execute each non-empty, non-command line.
      discard # Handled by outer loop logic for single lines

    if line.strip() == ":quit" or line.strip() == ":exit":
      echo "Exiting Nimlings shell. Bye!"
      break
    elif line.strip() == ":help":
      echo """
Nimlings Basic REPL Help:
  - Type any valid Nim expression or statement.
  - Multi-line input: Paste directly. Execution happens on pressing Enter after the full paste.
    (Note: True multi-line statement parsing is not yet implemented; it treats input as a block.)
  - :quit or :exit   - Exit the shell.
  - :help            - Show this help message.
"""
    # Add other commands like :clear if desired later
    else:
      # For now, execute every non-empty line. A real REPL would buffer until a complete expression/statement.
      # This basic version will just try to run the line.
      if line.strip().len > 0:
        let result = runTemporaryNimCode(line)
        if sandbox.CompilationFailed in result.flags:
          echo "Compilation Error:\n", result.compilationOutput
        elif sandbox.RuntimeFailed in result.flags:
          echo "Runtime Error:\n", result.runtimeOutput
        else: # Success (as per sandbox)
          if result.runtimeOutput.len > 0:
            echo result.runtimeOutput
          else:
            # No output, but successful execution (e.g. variable assignment)
            echo "OK (No output)"
      # If line is empty, just loop for next prompt.

  echo "---"


when isMainModule:
  dispatchMulti([hello, version, runExercise, hint, listExercises, watch, status, shell])
