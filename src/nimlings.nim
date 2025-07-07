import cligen

# Nimlings - A CLI tool for learning Nim
# This is the main entry point for the application.

proc hello*(name: string = "World") =
  ## Prints a greeting message.
  echo "Hello, " & name & "!"

proc version*() =
  ## Shows version information.
  echo "Nimlings Alpha Version 0.1.0"

import osproc
import os
import lessons
import state
import strutils
import sandbox
import times
import achievements
import sequtils
import ospaths
import tui/app as tuiApp

# Type to hold structured results from running an exercise
type
  ExerciseRunResult* = object # Exported for TUI module
    exercisePath*: string
    exerciseName*: string # For convenience
    success*: bool
    isCompilationFailure*: bool
    isRuntimeFailure*: bool
    isValidationFailure*: bool
    outputLog*: seq[string]
    earnedPointsMsg*: string
    newBadgesMsgs*: seq[string]

proc runExerciseLogic(exercisePathFragment: string): ExerciseRunResult =
  ## Core logic for running an exercise. Returns a structured result.
  var userState = loadState()
  let allExercises = discoverExercises() # discoverExercises needs to be available here

  result.exercisePath = "" # Initialize path
  result.exerciseName = "Unknown"

  let exerciseOpt = findExercise(exercisePathFragment, allExercises)
  if exerciseOpt.isNone:
    result.outputLog.add("Error: Exercise '" & exercisePathFragment & "' not found.")
    result.outputLog.add("Run `nimlings list` to see available exercises.")
    result.success = false
    return

  let exercise = exerciseOpt.get
  result.exercisePath = exercise.path # Store full path
  result.exerciseName = exercise.topic & "/" & exercise.name

  result.outputLog.add("Running exercise: " & result.exerciseName)
  result.outputLog.add("File: " & exercise.path)
  result.outputLog.add("WARNING: Exercises are run without a secure sandbox for native execution. WASM PoC is experimental. Do not run untrusted exercises.")
  result.outputLog.add("--------------------------------------------------")

  var sboxResult = sandbox.executeSandboxed(exercise.path, exercise.path.parentDir, preference = exercise.sandboxPreference)
  var overallSuccess = false
  var validationOutputLog: seq[string] # Separate log for validation messages

  if sandbox.CompilationFailed in sboxResult.flags:
    result.outputLog.add("❌ Compilation Failed ❌")
    result.outputLog.add(sboxResult.compilationOutput)
    result.isCompilationFailure = true
  elif sandbox.RuntimeFailed in sboxResult.flags:
    result.outputLog.add("💥 Runtime Error 💥")
    result.outputLog.add(sboxResult.runtimeOutput)
    result.isRuntimeFailure = true
  else:
    result.outputLog.add("✅ Compiled and Ran Successfully (according to sandbox).")
    result.outputLog.add("--- Output from your program ---")
    result.outputLog.add(sboxResult.runtimeOutput)
    result.outputLog.add("--- End of Output ---")

    let normalizedRuntimeOutput = sboxResult.runtimeOutput.strip().replace("\r\n", "\n")
    var currentFlags = sboxResult.flags # These are sandbox flags

    if exercise.expectedOutput.isSome:
      let expected = exercise.expectedOutput.get.strip().replace("\r\n", "\n")
      validationOutputLog.add("\n🔍 Validating output...")
      if normalizedRuntimeOutput == expected:
        currentFlags = {sandbox.Success}
        validationOutputLog.add("Output matches expected output.")
        overallSuccess = true
      else:
        currentFlags = {sandbox.ValidationFailed}
        validationOutputLog.add("Output does not match expected output.\nExpected:\n---\n" & expected &
                                 "\n---\nGot:\n---\n" & normalizedRuntimeOutput & "\n---")
        result.isValidationFailure = true
    elif exercise.validationScript.isSome:
      let scriptName = exercise.validationScript.get
      let scriptPath = exercise.path.parentDir / scriptName
      validationOutputLog.add("\n🔍 Running validation script: " & scriptPath)
      if fileExists(scriptPath):
        var validatorProc = startProcess("nim", args = ["e", "--hints:off", "--stdout:on", scriptPath],
                                         options = {poUsePath, poStdErrToStdOut, poParentStreams},
                                         workingDir = exercise.path.parentDir)
        var validatorStdout: string
        try:
          validatorProc.inputStream.write(sboxResult.runtimeOutput)
          validatorProc.inputStream.close()

          var validatorOutputLines: seq[string]
          while validatorProc.running:
              if validatorProc.peekExitCode != -1: break
              var line = validatorProc.outputStream.readLine()
              if line.len > 0: validatorOutputLines.add(line)
          validatorProc.close()
          validatorStdout = validatorOutputLines.join("\n")

          if validatorProc.peekExitCode == 0:
              currentFlags = {sandbox.Success}
              overallSuccess = true
          else:
              currentFlags = {sandbox.ValidationFailed}
              result.isValidationFailure = true
        except IOError as e:
          currentFlags = {sandbox.ValidationFailed}
          validatorStdout = "Failed to pipe output to validation script: " & getCurrentExceptionMsg()
          if validatorProc != nil: validatorProc.close()
          result.isValidationFailure = true

        validationOutputLog.add(validatorStdout)
      else:
        currentFlags = {sandbox.ValidationFailed}
        validationOutputLog.add("Validation script not found: " & scriptPath)
        result.isValidationFailure = true
    else: # No specific validation, successful sandbox run is enough
      overallSuccess = true
      currentFlags = {sandbox.Success} # Ensure this is set if no validation was needed

    sboxResult.flags = currentFlags # Update sandbox flags with validation outcome
    result.outputLog.add(validationOutputLog.join("\n"))


  result.outputLog.add("--------------------------------------------------")
  result.success = overallSuccess

  if overallSuccess:
    result.outputLog.add("🎉 Exercise completed successfully! 🎉")
    # Validation output (if any) is already in result.outputLog from validationOutputLog

    var justCompletedExercise = false
    if exercise.path notin userState.completedExercises:
      userState.completedExercises.add(exercise.path)
      userState.points += exercise.pointsValue
      justCompletedExercise = true
      saveState(userState)
      result.earnedPointsMsg = "Gained " & $exercise.pointsValue & " points! Total points: " & $userState.points
      result.outputLog.add(result.earnedPointsMsg)
      result.outputLog.add("Progress saved.")
    else:
      result.outputLog.add("This exercise was already completed. (No points or new badges from this completion)")

    if justCompletedExercise:
      let allExercisesList = discoverExercises()
      let newBadges = achievements.checkAndAwardBadges(userState, allExercisesList) # Modifies userState
      if newBadges.len > 0:
        result.outputLog.add("\n✨ You've earned new badges! ✨")
        for badge in newBadges:
          let badgeMsg = "  " & badge.emoji & " " & badge.name & " - " & badge.description
          result.outputLog.add(badgeMsg)
          result.newBadgesMsgs.add(badgeMsg)
        saveState(userState)
        result.outputLog.add("Badges saved.")
  else:
    result.outputLog.add("❌ Exercise failed. Please check the messages above and try again.")
    result.outputLog.add("Hint: " & (if exercise.hint.len > 0: exercise.hint else: "No hint available for this exercise."))

# CLI exposed `run` command
proc runExercise*(exerciseNameOrPath: string) =
  ## Compiles and runs the specified exercise.
  let result = runExerciseLogic(exerciseNameOrPath)
  for line in result.outputLog:
    echo line
  # Points and badge messages are already part of outputLog in runExerciseLogic's current form.
  # If they were separated more strictly, they would be printed here.

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

proc listExercises*(topicFilter: string = "", statusFilter: string = "", searchTerm: string = "") =
  ## Lists all available exercises and their completion status.
  ## Can be filtered by topic, status (todo, done), and/or search term (name/description).
  let userState = loadState()
  var exercisesToList = discoverExercises()
  var activeFilterMessages: seq[string]

  if topicFilter.len > 0:
    let lcFilter = topicFilter.toLower()
    exercisesToList = exercisesToList.filter(proc(ex: Exercise): bool = lcFilter in ex.topic.toLower())
    activeFilterMessages.add("topic containing '" & topicFilter & "'")

  if statusFilter.len > 0:
    let lcStatusFilter = statusFilter.toLower()
    if lcStatusFilter == "todo":
      exercisesToList = exercisesToList.filter(proc(ex: Exercise): bool = ex.path notin userState.completedExercises)
      activeFilterMessages.add("status: todo")
    elif lcStatusFilter == "done":
      exercisesToList = exercisesToList.filter(proc(ex: Exercise): bool = ex.path in userState.completedExercises)
      activeFilterMessages.add("status: done")
    else:
      echo "Invalid status filter '", statusFilter, "'. Use 'todo' or 'done'."
      return

  if searchTerm.len > 0:
    let lcSearchTerm = searchTerm.toLower()
    exercisesToList = exercisesToList.filter(proc(ex: Exercise): bool =
      (lcSearchTerm in ex.name.toLower()) or (lcSearchTerm in ex.description.toLower())
    )
    activeFilterMessages.add("name/desc containing '" & searchTerm & "'")

  if activeFilterMessages.len > 0:
    if exercisesToList.len == 0:
      echo "No exercises found matching filters: ", activeFilterMessages.join(" AND ")
      return
    else:
      echo "Showing exercises for filters: ", activeFilterMessages.join(" AND ")
  elif exercisesToList.len == 0 :
    echo "No exercises found. Please make sure the 'exercises' directory is set up correctly."
    return

  echo "\nAvailable exercises:"
  echo "Status | Topic          | Name              | Points | Description"
  echo "-------|----------------|-------------------|--------|------------------------------------"

  var currentTopicDisplay = ""
  for ex in exercisesToList:
    if ex.topic != currentTopicDisplay:
      if currentTopicDisplay != "":
        echo "-------|----------------|-------------------|--------|------------------------------------"
      currentTopicDisplay = ex.topic

    let statusSymbol = if ex.path in userState.completedExercises: "[DONE]" else: "[TODO]"
    let topicFormatted = ex.topic.align(14)
    let nameFormatted = ex.name.align(17)
    let pointsFormatted = $ex.pointsValue.align(6)

    echo statusSymbol, " | ", topicFormatted, " | ", nameFormatted, " | ", pointsFormatted, " | ", ex.description

  echo "---------------------------------------------------------------------------------------------"
  echo "Total Points: ", userState.points
  echo "Run an exercise using: nimlings run <exercise_name_or_path>"
  echo "Get a hint using: nimlings hint <exercise_name_or_path>"
  echo "Check your progress: nimlings status"

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

  runExercise(currentExercise.path) # This now calls the wrapper that prints
  userState = loadState()

  try:
    while true:
      sleep(1000)
      let modTime = getLastModificationTime(currentExercise.path)
      if modTime > lastModTime:
        echo "\nFile change detected. Re-running exercise..."
        lastModTime = modTime
        runExercise(currentExercise.path) # Wrapper call

        userState = loadState()
        if currentExercise.path in userState.completedExercises:
          echo "\n🎉 Great job on completing: ", currentExercise.name, "! 🎉"
          currentExerciseOpt = findNextPendingExercise(allExercises, userState)
          if currentExerciseOpt.isSome:
            currentExercise = currentExerciseOpt.get
            echo "\nNow watching next exercise: ", currentExercise.topic, "/", currentExercise.name
            echo "Path: ", currentExercise.path
            lastModTime = getLastModificationTime(currentExercise.path)
          else:
            echo "✨ You've completed all exercises! ✨"
            break

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

  if userState.earnedBadges.len > 0:
    echo "\n--- Earned Badges ---"
    for badgeId in userState.earnedBadges:
      let badgeOpt = achievements.getBadge(badgeId)
      if badgeOpt.isSome:
        let badge = badgeOpt.get
        echo "  ", badge.emoji, " ", badge.name, " - ", badge.description
      else:
        echo "  Unknown badge ID: ", badgeId
    echo "---------------------"
  else:
    echo "No badges earned yet. Keep going!"

  if completedCount == totalExercises && totalExercises > 0:
    echo "\n✨ Congratulations! You have completed all available exercises! ✨"
  elif totalExercises > 0 :
    let nextEx = findNextPendingExercise(allExercises, userState)
    if nextEx.isSome:
      echo "\nNext up: ", nextEx.get.topic, "/", nextEx.get.name
  else:
    echo "\nNo exercises found. Add some to the 'exercises' directory!"
  echo "---------------------------"

proc initExercise*(exercisePathFragment: string, workspace: string = "nimlings_workspace") =
  ## Copies a specified exercise to the user's workspace directory for solving.
  let allExercises = discoverExercises()
  let exerciseOpt = findExercise(exercisePathFragment, allExercises)

  if exerciseOpt.isNone:
    echo "Error: Exercise '", exercisePathFragment, "' not found in the Nimlings curriculum."
    return

  let sourceExercise = exerciseOpt.get
  let sourceExercisePath = sourceExercise.path

  var relativePath = ""
  let exercisesRoot = lessons.getExercisesRootPath()
  if sourceExercisePath.startsWith(exercisesRoot):
    let skipChars = if exercisesRoot.endsWith(DirSep): exercisesRoot.len else: exercisesRoot.len + 1
    relativePath = sourceExercisePath[skipChars .. ^1]
  else:
    relativePath = sourceExercisePath.extractFilename()
    echo "Warning: Could not determine relative path for exercise."

  if relativePath.len == 0:
      echo "Error: Could not determine a valid relative path for the exercise."
      return

  let targetWorkspacePath = workspace / relativePath
  let targetWorkspaceDir = targetWorkspacePath.parentDir()

  try:
    createDir(targetWorkspaceDir)
    copyFile(sourceExercisePath, targetWorkspacePath)
    echo "Exercise '", sourceExercise.name, "' initialized in workspace at:\n  ", targetWorkspacePath
    echo "\nEdit this file. To test, run: nim r ", targetWorkspacePath.quoteShell()
    echo "`nimlings run` checks exercises in the original 'exercises' directory."
  except OSError as e:
    echo "Error initializing exercise: ", e.msg
  except CatchableError as e:
    echo "Unexpected error during init: ", e.msg

import rdstdin

proc runTemporaryNimCode(userCode: string, context: string, tempFileName: string = "nimlings_repl_temp.nim"): sandbox.SandboxedExecutionResult =
  ## Writes the combined context + user code to a temporary file and runs it.
  let fullCode = if context.len > 0: context & "\n\n" & userCode else: userCode
  try:
    writeFile(tempFileName, fullCode)
  except IOError:
    var res: sandbox.SandboxedExecutionResult
    res.flags = {sandbox.CompilationFailed}
    res.compilationOutput = "Error: Could not write temporary file for REPL."
    return res

  let result = sandbox.executeSandboxed(tempFileName, getCurrentDir())

  if fileExists(tempFileName):
    try:
      removeFile(tempFileName)
    except OSError:
      echo "Warning: Could not clean up temporary REPL file: ", tempFileName

  return result

proc shell*() =
  ## Opens a basic interactive Nim shell (REPL).
  echo "Welcome to the Nimlings Interactive Shell (REPL)!"
  echo "Type Nim code. Use `:quit` or `:exit` to leave."
  echo "WARNING: Code is run via the sandbox module (not yet fully secure)."
  echo "---"
  var inputBuffer = ""
  var replContext = ""

  proc likelyContainsDeclarations(code: string): bool =
    for line in code.splitLines():
      let stripped = line.strip()
      if stripped.startsWith("var ") or stripped.startsWith("let ") or \
         stripped.startsWith("const ") or stripped.startsWith("type ") or \
         stripped.startsWith("proc ") or stripped.startsWith("iterator ") or \
         stripped.startsWith("macro ") or stripped.startsWith("template "):
        return true
    return false

  while true:
    let prompt = if inputBuffer.len == 0: "nim> " else: "nim| "
    stdout.write(prompt)
    stdout.flushFile()
    let line = readLine(stdin)
    let strippedLine = line.strip()

    if strippedLine == ":quit" or strippedLine == ":exit": break
    elif strippedLine == ":help":
      echo """REPL Commands:
  :quit, :exit   - Exit the shell.
  :help            - Show this help.
  :run             - Execute current buffer (or blank line after input).
  :show            - Show current buffer.
  :clear           - Clear current buffer.
  :show_context    - Show persistent REPL context.
  :clear_context   - Clear persistent REPL context."""
    elif strippedLine == ":run" or (line.len == 0 and inputBuffer.strip().len > 0) :
      if inputBuffer.strip().len > 0:
        let result = runTemporaryNimCode(inputBuffer, replContext)
        # Output handling from runTemporaryNimCode (which calls sandbox)
        if sandbox.CompilationFailed in result.flags:
          echo "Compilation Error:\n", result.compilationOutput
        elif sandbox.RuntimeFailed in result.flags:
          echo "Runtime Error:\n", result.runtimeOutput
        else: # Success from sandbox execution
          if result.runtimeOutput.len > 0: echo result.runtimeOutput
          else: echo "OK (No output)"

        # Context update logic (only if sandbox part was successful)
        if sandbox.Success in result.flags and likelyContainsDeclarations(inputBuffer):
          if replContext.len > 0: replContext &= "\n" & inputBuffer
          else: replContext = inputBuffer
          echo "(Context updated)"
        inputBuffer = ""
      elif strippedLine == ":run": echo "Buffer is empty."
    elif strippedLine == ":clear": inputBuffer = ""; echo "Input buffer cleared."
    elif strippedLine == ":show":
      if inputBuffer.len > 0: echo "--- Buffer ---\n", inputBuffer, "\n--------------"
      else: echo "Input buffer is empty."
    elif strippedLine == ":show_context":
      if replContext.len > 0: echo "--- Context ---\n", replContext, "\n---------------"
      else: echo "REPL context is empty."
    elif strippedLine == ":clear_context": replContext = ""; echo "REPL context cleared."
    elif line.len == 0: continue
    else:
      if inputBuffer.len > 0: inputBuffer &= "\n" & line
      else: inputBuffer = line
  echo "---"

proc tui*() =
  ## Starts the Nimlings Text User Interface (experimental).
  echo "TUI mode selected. Initializing..."
  tuiApp.runTuiApp()

when isMainModule:
  dispatchMulti([hello, version, runExercise, hint, listExercises, watch, status, shell, initExercise, tui])
