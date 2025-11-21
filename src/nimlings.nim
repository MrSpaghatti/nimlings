
import os, parseopt, strutils, std/sets
import engine, tui, types, content, models

when NimMajor < 1 or (NimMajor == 1 and NimMinor < 6):
  {.error: "Nim 1.6 or higher is required to build nimlings.".}

proc printHelp() =
  echo "nimlings: An interactive tutor for the Nim programming language."
  echo ""
  echo "Usage:"
  echo "  nimlings learn [lesson_id]   Start the TUI (default)"
  echo "  nimlings list                List all lessons"
  echo "  nimlings reset               Reset progress"
  echo "  nimlings test                Run internal tests"
  echo "  nimlings hint <id>           Show hint"
  echo "  nimlings solution <id>       Show solution"

proc main() =
  checkNimInstalled()
  initLessons() # Load content

  var p = initOptParser(quoteShellCommand(commandLineParams()))
  var cmd = "learn"
  var arg = ""

  # Basic parsing
  if paramCount() > 0:
    cmd = paramStr(1)
    if paramCount() > 1:
      arg = paramStr(2)

  case cmd
  of "learn":
    runTUI()
  of "list":
    let p = loadProgress()
    echo "=== Nimlings Curriculum ===\n"
    for m in modules:
      echo m.name & ":"
      for l in m.lessons:
        let marker = if l.id in p: "[x]" else: "[ ]"
        echo "  " & marker & " " & l.id & ": " & l.name
      echo ""
  of "reset":
    # Clear files
    let cd = getHomeDir() / ".config" / "nimlings"
    removeFile(cd / "progress.json")
    removeFile(cd / "state.json")
    echo "Progress reset."
  of "test":
    echo "Running internal tests..."
    var passed = 0
    var failed = 0
    for m in modules:
      for l in m.lessons:
        if l.validate == nil: continue # Should verify function pointer?
        # Intro lessons usually return true or have simple validation.
        # We need to run the solution code.
        echo "Testing ", l.id, ": ", l.name, "..."
        let res = runCode(l, l.solution)
        let (ok, msg) = validate(l, l.solution, res)
        if ok:
          passed += 1
        else:
          failed += 1
          echo "FAILED: ", l.id
          echo msg

    if failed > 0:
      echo "\nPassed: ", passed, ", Failed: ", failed
      quit(1)
    else:
      echo "All passed."
  of "hint":
    # find lesson
    # naive search
    for m in modules:
      for l in m.lessons:
        if l.id == arg:
          echo "=== Hint for ", l.id, " ==="
          echo l.hint
          return
    echo "Lesson not found."
  of "solution":
    for m in modules:
      for l in m.lessons:
        if l.id == arg:
          echo "=== Solution for ", l.id, " ==="
          echo l.solution
          return
    echo "Lesson not found."
  else:
    printHelp()

when isMainModule:
  main()
