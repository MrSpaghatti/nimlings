# Nimlings TUI Application
# This module will manage the Text User Interface.

import illwill
import os
import lessons
import state
import strutils
import sandbox

# A simple structure to manage the layout
type
  Rect = object
    x, y, w, h: int

  Window = object
    bounds: Rect
    title: string

proc drawWindow(win: Window) =
  # Draw the window border
  for i in win.bounds.x ..< (win.bounds.x + win.bounds.w):
    illwill.writeAt(i, win.bounds.y, '─')
    illwill.writeAt(i, win.bounds.y + win.bounds.h - 1, '─')

  for i in win.bounds.y ..< (win.bounds.y + win.bounds.h):
    illwill.writeAt(win.bounds.x, i, '│')
    illwill.writeAt(win.bounds.x + win.bounds.w - 1, i, '│')

  illwill.writeAt(win.bounds.x, win.bounds.y, '┌')
  illwill.writeAt(win.bounds.x + win.bounds.w - 1, win.bounds.y, '┐')
  illwill.writeAt(win.bounds.x, win.bounds.y + win.bounds.h - 1, '└')
  illwill.writeAt(win.bounds.x + win.bounds.w - 1, win.bounds.y + win.bounds.h - 1, '┘')

  # Draw the title
  illwill.writeAt(win.bounds.x + 2, win.bounds.y, "[ " & win.title & " ]")


proc runTuiApp*() =
  echo "Attempting to initialize TUI..."
  if not illwill.initialize():
    stderr.writeLine "Failed to initialize illwill (TUI library)."
    quit(1)
  defer: illwill.terminate()

  var running = true
  while running:
    illwill.clear()
    let (w, h) = illwill.getTerminalSize()

    # Define the layout
    let exerciseListPane = Window(bounds: Rect(x: 0, y: 0, w: w div 3, h: h), title: "Exercises")
    let codePane = Window(bounds: Rect(x: w div 3, y: 0, w: (w - w div 3), h: h * 2 div 3), title: "Code")
    let outputPane = Window(bounds: Rect(x: w div 3, y: h * 2 div 3, w: (w - w div 3), h: h - (h * 2 div 3)), title: "Output")

    # Draw the windows
    drawWindow(exerciseListPane)
    drawWindow(codePane)
    drawWindow(outputPane)

    # Display the exercises
    let exercises = discoverExercises()
    let userState = loadState()
    var y = exerciseListPane.bounds.y + 1
    for i, exercise in exercises:
      if y < exerciseListPane.bounds.y + exerciseListPane.bounds.h - 1:
        let statusSymbol = if exercise.path in userState.completedExercises: "[DONE]" else: "[TODO]"
        let line = &"{statusSymbol} {exercise.name}"
        illwill.writeAt(exerciseListPane.bounds.x + 1, y, line)
        y += 1

    # Display the code of the first exercise
    if exercises.len > 0:
      let exercise = exercises[0]
      let code = readFile(exercise.path)
      let lines = code.splitLines()
      var codeY = codePane.bounds.y + 1
      for i, line in lines:
        if codeY < codePane.bounds.y + codePane.bounds.h - 1:
          illwill.writeAt(codePane.bounds.x + 1, codeY, line)
          codeY += 1

    # Run the first exercise and display the output
    if exercises.len > 0:
        let exercise = exercises[0]
        let result = sandbox.executeSandboxed(exercise.path, exercise.path.parentDir)
        let output = result.compilationOutput & "\n" & result.runtimeOutput
        let outputLines = output.splitLines()
        var outputY = outputPane.bounds.y + 1
        for i, line in outputLines:
            if outputY < outputPane.bounds.y + outputPane.bounds.h - 1:
                illwill.writeAt(outputPane.bounds.x + 1, outputY, line)
                outputY += 1

    illwill.flush()

    # Event handling
    let event = illwill.pollEvent()
    if event.kind == EventKind.Key:
      case event.key
      of Key.Q, Key.q: # Quit on 'q'
        running = false
      else:
        discard # Ignore other keys for now
    elif event.kind == EventKind.Resize:
      illwill.clear() # Clear on resize to redraw cleanly

  illwill.clear()
  illwill.flush()
  echo "TUI Exited."
