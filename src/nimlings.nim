
import os, parseopt, strutils, std/sets, times, threadpool
import engine, tui, types, content, models

when NimMajor < 1 or (NimMajor == 1 and NimMinor < 6):
  {.error: "Nim 1.6 or higher is required to build nimlings.".}

proc printHelp() =
  echo "nimlings: An interactive tutor for the Nim programming language."
  echo ""
  echo "Usage:"
  echo "  nimlings learn [lesson_id]   Start the TUI (default)"
  echo "  nimlings watch [lesson_id]   Start CLI Watch Mode"
  echo "  nimlings list                List all lessons"
  echo "  nimlings reset               Reset progress"
  echo "  nimlings test                Run internal tests"
  echo "  nimlings hint <id>           Show hint"
  echo "  nimlings solution <id>       Show solution"

# --- Watch Mode Logic ---
proc findLesson(id: string): (bool, Lesson) =
  for m in modules:
    for l in m.lessons:
      if l.id == id: return (true, l)
  return (false, Lesson())

proc findNextLesson(id: string): Lesson =
  var found = false
  for m in modules:
    for l in m.lessons:
      if found: return l
      if l.id == id: found = true
  return Lesson() # Empty if last

proc runWatchMode(startId: string) =
  var currentId = startId

  # If no startId, pick first unfinished
  if currentId == "":
    let p = loadProgress()
    var foundUnfinished = false
    for m in modules:
      for l in m.lessons:
        if l.id notin p:
          currentId = l.id
          foundUnfinished = true
          break
      if foundUnfinished: break
    if currentId == "": currentId = "1.1"

  while true:
    let (ok, lesson) = findLesson(currentId)
    if not ok:
      echo "Error: Lesson not found: ", currentId
      quit(1)

    # Ensure file
    let path = ensureLessonFile(lesson)
    echo "\n========================================"
    echo "  WATCHING: ", lesson.id, ": ", lesson.name
    echo "  File: ", path
    echo "  Edit this file to complete the lesson."
    echo "========================================\n"

    var lastTime = getLastModificationTime(path)

    # Validation Loop
    while true:
      # Initial check
      echo "Compiling..."
      let code = readFile(path)
      let res = runCode(lesson, code)
      let (success, msg) = validate(lesson, code, res)

      echo msg

      if success:
        echo "\n[SUCCESS] Lesson Complete!"
        var p = loadProgress()
        p.incl(lesson.id)
        saveProgress(p)

        let next = findNextLesson(lesson.id)
        if next.id != "":
          echo "Press Enter to continue to next lesson (" & next.id & ")..."
          discard stdin.readLine()
          currentId = next.id
          break # Break inner loop, proceed to next lesson
        else:
          echo "Congratulations! You have completed the course."
          quit(0)

      echo "\nWaiting for changes..."

      # Watch loop
      while true:
        sleep(500)
        try:
          let t = getLastModificationTime(path)
          if t > lastTime:
            lastTime = t
            echo "\n[DETECTED] File changed. Re-checking..."
            break # Break watch loop, re-run check
        except:
          discard

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
  of "watch":
    runWatchMode(arg)
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
