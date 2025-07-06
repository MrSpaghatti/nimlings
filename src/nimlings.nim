import cligen

# Nimlings - A CLI tool for learning Nim
# This is the main entry point for the application.

proc hello*(name: string = "World") =
  ## Prints a greeting message.
  echo "Hello, " & name & "!"

proc version*() =
  ## Shows version information.
  echo "Nimlings Alpha Version 0.1.0"

import osproc # Still needed for validation script execution
import os
import lessons
import state
import strutils
import sandbox
import times
import achievements # For badges
import sequtils     # For .filter

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
  echo "WARNING: Exercises are run without a secure sandbox. Do not run untrusted exercises."
  echo "--------------------------------------------------"

  var sboxResult = sandbox.executeSandboxed(exercise.path, exercise.path.parentDir, preference = exercise.sandboxPreference)
  var overallSuccess = false
  var validationRunOutput = ""

  if sandbox.CompilationFailed in sboxResult.flags:
    echo "❌ Compilation Failed ❌"
    echo sboxResult.compilationOutput
  elif sandbox.RuntimeFailed in sboxResult.flags:
    echo "💥 Runtime Error 💥"
    echo sboxResult.runtimeOutput
  else:
    echo "✅ Compiled and Ran Successfully (according to sandbox)."
    echo "--- Output from your program ---"
    echo sboxResult.runtimeOutput
    echo "--- End of Output ---"

    let normalizedRuntimeOutput = sboxResult.runtimeOutput.strip().replace("\r\n", "\n")
    var currentFlags = sboxResult.flags

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
      overallSuccess = true
      currentFlags = {sandbox.Success}

    sboxResult.flags = currentFlags

  echo "--------------------------------------------------"

  if overallSuccess:
    echo "🎉 Exercise completed successfully! 🎉"
    if validationRunOutput.len > 0 : echo "Validation: ", validationRunOutput

    var justCompletedExercise = false
    if exercise.path notin userState.completedExercises:
      userState.completedExercises.add(exercise.path)
      userState.points += exercise.pointsValue
      justCompletedExercise = true
      saveState(userState)
      echo "Gained ", exercise.pointsValue, " points! Total points: ", userState.points
      echo "Progress saved."
    else:
      echo "This exercise was already completed. (No points or new badges from this completion)"

    if justCompletedExercise:
      let allExercisesList = discoverExercises()
      let newBadges = achievements.checkAndAwardBadges(userState, allExercisesList)
      if newBadges.len > 0:
        echo "\n✨ You've earned new badges! ✨"
        for badge in newBadges:
          echo "  ", badge.emoji, " ", badge.name, " - ", badge.description
        saveState(userState)
        echo "Badges saved."
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

proc listExercises*(topicFilter: string = "", statusFilter: string = "", searchTerm: string = "") =
  ## Lists all available exercises and their completion status.
  ## Can be filtered by topic, status (todo, done), and/or search term (name/description).
  let userState = loadState()
  var exercisesToList = discoverExercises() # Start with all exercises
  var activeFilterMessages: seq[string]

  # Apply topic filter
  if topicFilter.len > 0:
    let lcFilter = topicFilter.toLower()
    exercisesToList = exercisesToList.filter(proc(ex: Exercise): bool = lcFilter in ex.topic.toLower())
    activeFilterMessages.add("topic containing '" & topicFilter & "'")

  # Apply status filter
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

  # Apply search term filter
  if searchTerm.len > 0:
    let lcSearchTerm = searchTerm.toLower()
    exercisesToList = exercisesToList.filter(proc(ex: Exercise): bool =
      (lcSearchTerm in ex.name.toLower()) or (lcSearchTerm in ex.description.toLower())
    )
    activeFilterMessages.add("name/desc containing '" & searchTerm & "'")

  # Report if filters are active and if they resulted in no matches
  if activeFilterMessages.len > 0:
    if exercisesToList.len == 0:
      echo "No exercises found matching filters: ", activeFilterMessages.join(" AND ")
      return
    else:
      echo "Showing exercises for filters: ", activeFilterMessages.join(" AND ")
  elif exercisesToList.len == 0 :
    echo "No exercises found. Please make sure the 'exercises' directory is set up correctly."
    return

  # Display the (potentially filtered) list
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

  runExercise(currentExercise.path)
  userState = loadState()

  try:
    while true:
      sleep(1000)
      let modTime = getLastModificationTime(currentExercise.path)
      if modTime > lastModTime:
        echo "\nFile change detected. Re-running exercise..."
        lastModTime = modTime
        runExercise(currentExercise.path)

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
  ## Type `:quit` or `:exit` to leave the shell.
  echo "Welcome to the Nimlings Interactive Shell (REPL)!"
  echo "Type Nim code directly. Use `:quit` or `:exit` to leave."
  echo "WARNING: Code is run via the sandbox module, which is not yet secure."
  echo "---"

  var inputBuffer: string = ""
  var replContext: string = ""

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

    if strippedLine == ":quit" or strippedLine == ":exit":
      echo "Exiting Nimlings shell. Bye!"
      break
    elif strippedLine == ":help":
      echo """
Nimlings Enhanced REPL Help:
  - Type Nim code. It will be added to a buffer.
  - Enter a blank line or type `:run` to execute the buffered code.
  - Multi-line input is supported; lines are collected until you execute.
  - :quit or :exit   - Exit the shell.
  - :help            - Show this help message.
  - :run             - Execute the current code in the buffer.
  - :show            - Show the current code in the buffer without running.
  - :clear           - Clear the current code buffer.
  - :show_context    - Show the persistent REPL context.
  - :clear_context   - Clear the persistent REPL context.
"""
    elif strippedLine == ":run" or (line.len == 0 and inputBuffer.strip().len > 0) :
      if inputBuffer.strip().len > 0:
        let result = runTemporaryNimCode(inputBuffer, replContext)
        if sandbox.CompilationFailed in result.flags:
          echo "Compilation Error:\n", result.compilationOutput
          if replContext.len > 0:
            echo "Note: An error occurred while using the REPL context. Try `:clear_context` if issues persist."
        elif sandbox.RuntimeFailed in result.flags:
          echo "Runtime Error:\n", result.runtimeOutput
          if replContext.len > 0:
            echo "Note: An error occurred while using the REPL context. Try `:clear_context` if issues persist."
        else:
          if result.runtimeOutput.len > 0:
            echo result.runtimeOutput
          else:
            echo "OK (No output)"

          if likelyContainsDeclarations(inputBuffer):
            if replContext.len > 0:
              replContext &= "\n" & inputBuffer
            else:
              replContext = inputBuffer
            echo "(Context updated)"

        inputBuffer = ""
      elif strippedLine == ":run":
        echo "Buffer is empty. Type some code or :help."
    elif strippedLine == ":clear":
      inputBuffer = ""
      echo "Input buffer cleared."
    elif strippedLine == ":show":
      if inputBuffer.len > 0:
        echo "--- Current Input Buffer ---"
        echo inputBuffer
        echo "--------------------------"
      else:
        echo "Input buffer is empty."
    elif strippedLine == ":show_context":
      if replContext.len > 0:
        echo "--- REPL Context ---"
        echo replContext
        echo "--------------------"
      else:
        echo "REPL context is empty."
    elif strippedLine == ":clear_context":
      replContext = ""
      echo "REPL context cleared."
    elif line.len == 0:
        continue
    else:
      if inputBuffer.len > 0:
        inputBuffer &= "\n" & line
      else:
        inputBuffer = line
  echo "---"

when isMainModule:
  dispatchMulti([hello, version, runExercise, hint, listExercises, watch, status, shell])
