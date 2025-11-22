
import os, parseopt, strutils, std/sets, times, threadpool, json
import engine, tui, types, content, models

# Version constant (match nimble file)
const NimlingsVersion = "2.0.0"

when NimMajor < 1 or (NimMajor == 1 and NimMinor < 6):
  {.error: "Nim 1.6 or higher is required to build nimlings.".}

proc printHelp() =
  echo "nimlings: An interactive tutor for the Nim programming language."
  echo ""
  echo "Usage: nimlings [options] [command] [args]"
  echo ""
  echo "Commands:"
  echo "  learn [lesson_id]         Start the TUI (default)"
  echo "  watch [lesson_id]         Start CLI Watch Mode"
  echo "  list                      List all lessons"
  echo "  reset                     Reset progress"
  echo "  test                      Run internal tests"
  echo "  hint <lesson_id>          Show hint for a lesson"
  echo "  solution <lesson_id>      Show solution for a lesson"
  echo "  export                    Export progress to stdout (JSON)"
  echo "  import [file]             Import progress from file (or stdin)"
  echo ""
  echo "Options:"
  echo "  -h, --help                Show this help message"
  echo "  -v, --version             Show version"
  echo ""
  echo "Config:"
  echo "  Progress and state are stored in: ~/.config/nimlings/"
  echo ""
  echo "For more information, visit: https://github.com/nim-lang/nimlings"

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
  # Move checkNimInstalled later to avoid noise on help/version/list

  initLessons() # Load content

  var p = initOptParser(quoteShellCommand(commandLineParams()))

  # Handle flags first if they appear as first argument
  if paramCount() > 0:
    let first = paramStr(1)
    if first == "-h" or first == "--help":
      printHelp()
      quit(0)
    if first == "-v" or first == "--version":
      echo "nimlings " & NimlingsVersion
      quit(0)

  var cmd = "learn"
  var arg = ""

  # Basic parsing for subcommands
  if paramCount() > 0:
    cmd = paramStr(1)
    if paramCount() > 1:
      arg = paramStr(2)

  case cmd
  of "learn":
    checkNimInstalled()
    runTUI()
  of "watch":
    checkNimInstalled()
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
    checkNimInstalled()
    echo "Running internal tests..."
    var passed = 0
    var failed = 0
    for m in modules:
      for l in m.lessons:
        if l.validate == nil: continue
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
    if arg == "":
      printHelp()
      quit(1)
    var found = false
    for m in modules:
      for l in m.lessons:
        if l.id == arg:
          echo "=== Hint for ", l.id, " ==="
          echo l.hint
          found = true
          break
      if found: break
    if not found:
      echo "Lesson not found: ", arg
      quit(1)
  of "solution":
    if arg == "":
      printHelp()
      quit(1)
    var found = false
    for m in modules:
      for l in m.lessons:
        if l.id == arg:
          echo "=== Solution for ", l.id, " ==="
          echo l.solution
          found = true
          break
      if found: break
    if not found:
      echo "Lesson not found: ", arg
      quit(1)
  of "export":
    let cd = getHomeDir() / ".config" / "nimlings"
    if fileExists(cd / "progress.json"):
      echo readFile(cd / "progress.json")
    else:
      echo "[]"
  of "import":
    var content = ""
    if arg != "":
      if fileExists(arg):
        content = readFile(arg)
      else:
        echo "Error: File not found: ", arg
        quit(1)
    else:
      try:
        content = stdin.readAll()
      except EOFError:
        echo "Error: No input provided."
        quit(1)

    try:
      let imported = parseJson(content)
      if imported.kind != JArray:
        echo "Error: Invalid JSON format (expected array)"
        quit(1)

      var p = loadProgress()
      var count = 0
      for item in imported.getElems():
        if item.kind == JString:
          let id = item.getStr()
          if id notin p:
            p.incl(id)
            count.inc()

      saveProgress(p)
      echo "Imported ", count, " new progress items."
    except JsonParsingError:
      echo "Error: Invalid JSON"
      quit(1)
  else:
    printHelp()
    quit(1)

when isMainModule:
  main()
