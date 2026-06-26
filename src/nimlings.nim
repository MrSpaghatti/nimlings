import os, std/sets, times, json
when defined(posix):
  import posix
import engine, tui, types, content, models

# Version constant (match nimble file)
const NimlingsVersion = "2.1.3"

when NimMajor < 1 or (NimMajor == 1 and NimMinor < 6):
  {.error: "Nim 1.6 or higher is required to build nimlings.".}

proc printHelp() =
  echo """nimlings: An interactive tutor for the Nim programming language.

Usage: nimlings [options] [command] [args]

Commands:
  learn [lesson_id]         Show dashboard and start watch mode (default)
  watch [lesson_id]         Watch a lesson and auto-validate on save
  list                      Show progress dashboard
  path                      Show recommended upgrade path
  status                    Quick daily status (for shell greeting)
  reset                     Reset progress
  test                      Run internal tests
  hint <lesson_id>          Show hint for a lesson
  solution <lesson_id>      Show solution for a lesson
  export                    Export progress to stdout (JSON)
  import [file]             Import progress from file (or stdin)

Options:
  -h, --help                Show this help message
  -v, --version             Show version
  -f, --force               Skip prerequisite checks

Config:
  Progress and state are stored in: ~/.config/nimlings/

Quick start:
  nimlings learn            Start from the beginning
  nimlings path             See your upgrade path
  nimlings list             See your progress
  nimlings watch 4.9.1      Jump to any lesson (--force to skip prereqs)"""

# ── Helpers ─────────────────────────────────────────────────────────

proc findLesson(id: string): (bool, Lesson) =
  for level in levels:
    for chapter in level.chapters:
      for l in chapter.lessons:
        if l.id == id: return (true, l)
  return (false, Lesson())

proc findLessonById(id: string): Lesson =
  let (found, lesson) = findLesson(id)
  if not found:
    echo "Lesson not found: ", id
    quit(1)
  return lesson

proc findNextUnfinished(): string =
  let p = loadProgress()
  for level in levels:
    for chapter in level.chapters:
      for l in chapter.lessons:
        if l.id notin p and canSkip(l, p):
          return l.id
  return ""

proc findNextLesson(id: string, force: bool = false): Lesson =
  let p = loadProgress()
  var found = false
  for level in levels:
    for chapter in level.chapters:
      for l in chapter.lessons:
        if found:
          if force or canSkip(l, p):
            return l
        if l.id == id: found = true
  return Lesson()

# ── Watch Mode ──────────────────────────────────────────────────────

proc runWatchMode(startId: string, force: bool = false) =
  var currentId = startId
  if currentId == "":
    currentId = findNextUnfinished()
    if currentId == "":
      printDashboard()
      echo "  " & bold("All lessons complete!") & " Run " & bold("nimlings list") & " to see your progress."
      return

  # Check prerequisites
  if not force:
    let p0 = loadProgress()
    if not canSkip(currentId, p0):
      printDashboard()
      echo "  " & bold(Yellow & "⚠️  Prerequisites not met!" & Reset)
      echo "  " & dim("You need to complete the following first:")
      let (_, lesson) = findLesson(currentId)
      for pre in lesson.prerequisites:
        if pre notin p0:
          echo "    - " & pre
      echo ""
      echo "  " & dim("Use --force to skip this check.")
      quit(0)

  # Mark the lesson directory for this session
  while true:
    let (ok, lesson) = findLesson(currentId)
    if not ok:
      echo "Error: Lesson not found: ", currentId
      quit(1)

    # Ensure exercise file exists
    let path = ensureLessonFile(lesson)
    printLessonHeader(lesson)

    var lastTime = getLastModificationTime(path)

    # Initial check
    echo bold("  Compiling & checking...")
    let code = readFile(path)
    let res = runCode(lesson, code)
    let (success, msg) = validate(lesson, code, res)
    printOutput(msg)

    if success:
      printSuccess(lesson)
      var p = loadProgress()
      p.incl(lesson.id)
      saveProgress(p)
      recordLessonCompletion()

      let next = findNextLesson(lesson.id, force)
      if next.id != "":
        echo dim("  Press Enter to continue to " & next.id & ": " & next.name & " ...")
        discard stdin.readLine()
        currentId = next.id
        continue
      else:
        echo bold(Green & "  🎉 Congratulations! You completed the entire course!" & Reset)
        quit(0)

    echo dim("  Waiting for changes to " & path & " ...")

    # Watch loop
    var dotCount = 0
    while true:
      sleep(500)
      dotCount.inc
      let t = try: getLastModificationTime(path)
              except: Time.high
      if t > lastTime:
        lastTime = t
        echo dim("  [file changed] Re-checking...")
        break
      # Show a spinner every 2 seconds
      if dotCount mod 4 == 0:
        write(stdout, dim("."))
        flushFile(stdout)

# ── Main ────────────────────────────────────────────────────────────

proc main() =
  initLessons()

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
  var force = false

  var i = 1
  while i <= paramCount():
    let p = paramStr(i)
    if p == "--force" or p == "-f":
      force = true
      i += 1
    elif cmd == "learn" and p != "learn":
      cmd = p
      i += 1
    elif arg == "":
      arg = p
      i += 1
    else:
      i += 1

  case cmd
  of "learn":
    checkNimInstalled()
    printDashboard()
    echo dim("  Starting watch mode... (Ctrl+C to quit)")
    runWatchMode(arg, force)
  of "watch":
    checkNimInstalled()
    runWatchMode(arg, force)
  of "list":
    printDashboard()
  of "reset":
    let cd = getHomeDir() / ".config" / "nimlings"
    removeFile(cd / "progress.json")
    removeFile(cd / "state.json")
    echo "Progress reset."
  of "test":
    checkNimInstalled()
    var passed = 0
    var failed = 0
    for level in levels:
      for chapter in level.chapters:
        for l in chapter.lessons:
          if l.validate == nil: continue
          let res = runCode(l, l.solution)
          let (ok, msg) = validate(l, l.solution, res)
          if ok:
            passed += 1
          else:
            failed += 1
            echo Red & "FAILED: " & Reset & l.id
            printOutput(msg)

    if failed > 0:
      echo "\n" & Red & Bold & "Passed: " & $passed & ", Failed: " & $failed & Reset
      quit(1)
    else:
      echo Green & Bold & "All " & $passed & " passed." & Reset
  of "hint":
    if arg == "":
      printHelp()
      quit(1)
    let lesson = findLessonById(arg)
    echo bold("Hint for " & lesson.id) & ": " & lesson.hint
  of "solution":
    if arg == "":
      printHelp()
      quit(1)
    let lesson = findLessonById(arg)
    echo bold("Solution for " & lesson.id) & ":"
    echo lesson.solution
  of "export":
    let cd = getHomeDir() / ".config" / "nimlings"
    if fileExists(cd / "progress.json"):
      echo readFile(cd / "progress.json")
    else:
      echo "[]"
  of "status":
    checkNimInstalled()
    let saved = loadProgress()
    let daily = loadDaily()

    # Count totals
    var total = 0
    for level in levels:
      for chapter in level.chapters:
        for l in chapter.lessons:
          total.inc

    echo ""
    echo bold("  nimlings ") & dim($saved.len & "/" & $total & " lessons")
    if daily.streak > 0:
      echo "  Streak: " & bold(Green & $daily.streak & " days" & Reset)
    else:
      echo "  Streak: " & dim("no lessons yet")
    if daily.lessonsToday > 0:
      echo "  Today: " & $daily.lessonsToday & " lesson(s) done"
    else:
      echo "  Today: " & dim("not yet — run ") & bold("nimlings learn") & dim(" to start")
    echo ""
  of "path":
    let p = loadProgress()
    echo ""
    echo bold("  Recommended Upgrade Path")
    echo ""
    var foundNext = false
    for level in levels:
      for chapter in level.chapters:
        for l in chapter.lessons:
          if l.id in p:
            echo "    " & Green & "✓" & Reset & " " & l.id & ": " & l.name
          elif not foundNext and canSkip(l.id, p):
            echo "    " & Yellow & "▸" & Reset & " " & l.id & ": " & l.name & dim(" ← next")
            foundNext = true
          else:
            let unlocked = canSkip(l.id, p)
            if unlocked:
              echo "    " & Grey & "◇" & Reset & " " & l.id & ": " & l.name
            else:
              echo "    " & Red & "◇" & Reset & " " & l.id & ": " & dim(l.name)
    echo ""
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
        when defined(posix):
          if isatty(stdin.getFileHandle()) == 1:
            echo "Reading from stdin... (Press Ctrl+D when done)"
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
    except JsonKindError:
      echo "Error: Invalid JSON structure"
      quit(1)
  else:
    printHelp()
    quit(1)

when isMainModule:
  main()
