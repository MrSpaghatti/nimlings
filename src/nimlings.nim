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
import lessons # Assuming lessons.nim is in the same directory or accessible
import state   # Assuming state.nim is in the same directory or accessible

proc compileAndRun(filePath: string): tuple[output: string, success: bool] =
  let nimexe = "nim" # Assuming nim compiler is in PATH
  # Compile and run in one step. Output to a temporary file to avoid clutter.
  # `nim compile --run <file>` or `nim c -r <file>`
  # We'll use `nim check` first for faster feedback on errors, then `nim compile -r` if check passes.

  var p = startProcess(nimexe, args = ["check", filePath], options = {poStdErrToStdOut, poUsePath})
  var outputLines: seq[string]
  while p.running():
    if p.peekExitCode != -1: break # process finished
    var line = p.outputStream().readLine()
    if line.len > 0:
      outputLines.add(line)
  p.close()
  let checkExitCode = p.peekExitCode()
  let fullOutput = outputLines.join("\n")

  if checkExitCode != 0:
    return (fullOutput, false)

  # If check is successful, then compile and run
  outputLines = @[] # Reset for run output
  p = startProcess(nimexe, args = ["compile", "--run", "--hints:off", "--verbosity:0", filePath], options = {poStdErrToStdOut, poUsePath})
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0:
      outputLines.add(line)
  p.close()
  let runExitCode = p.peekExitCode()
  let runOutput = outputLines.join("\n")

  if runExitCode == 0:
    return (runOutput, true)
  else:
    # This case might happen if 'check' passes but runtime fails, or if compile itself fails after check (less likely for simple exercises)
    return (runOutput, false)


proc runExercise*(exerciseNameOrPath: string) =
  ## Compiles and runs the specified exercise.
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
  echo "--------------------------------------------------"

  let (output, success) = compileAndRun(exercise.path)

  echo output
  echo "--------------------------------------------------"

  if success:
    echo "🎉 Exercise completed successfully! 🎉"
    if exercise.path notin userState.completedExercises:
      userState.completedExercises.add(exercise.path)
      saveState(userState)
      echo "Progress saved."
    else:
      echo "This exercise was already completed."
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
  echo "Status | Topic          | Name              | Description"
  echo "-------|----------------|-------------------|------------------------------------"

  var currentTopic = ""
  for ex in allExercises:
    if ex.topic != currentTopic:
      if currentTopic != "": # Add a separator line between topics, but not before the first one
        echo "-------|----------------|-------------------|------------------------------------"
      currentTopic = ex.topic
      # echo "Topic: ", ex.topic # Alternative way to group, but table is cleaner

    let status = if ex.path in userState.completedExercises: "[DONE]" else: "[TODO]"
    let topicFormatted = ex.topic.align(14) # Adjust alignment as needed
    let nameFormatted = ex.name.align(17)   # Adjust alignment

    echo status, " | ", topicFormatted, " | ", nameFormatted, " | ", ex.description

  echo "-------------------------------------------------------------------------------------"
  echo "Run an exercise using: nimlings run <exercise_name_or_path>"
  echo "Get a hint using: nimlings hint <exercise_name_or_path>"


when isMainModule:
  dispatchMulti([hello, version, runExercise, hint, listExercises])
