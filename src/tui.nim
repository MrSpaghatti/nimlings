import strutils, std/sets
import types, content, models, engine

# ── ANSI helpers ────────────────────────────────────────────────────

const
  Reset* = "\e[0m"
  Bold* = "\e[1m"
  Dim* = "\e[2m"

  Red* = "\e[31m"
  Green* = "\e[32m"
  Yellow* = "\e[33m"
  Blue* = "\e[34m"
  Magenta* = "\e[35m"
  Cyan* = "\e[36m"
  White* = "\e[37m"
  Grey* = "\e[90m"

proc dim*(s: string): string = Dim & s & Reset
proc bold*(s: string): string = Bold & s & Reset
proc colored*(s: string, c: string): string = c & s & Reset

# ── Progress bar ────────────────────────────────────────────────────

proc progressBar(filled, total, width: int): string =
  if total == 0: return repeat(" ", width)
  let done = (filled.float / total.float * width.float).int
  let pct = (filled.float / total.float * 100.0).int
  let bar = repeat("█", done) & repeat("░", width - done)
  Green & bar & Reset & " " & $pct & "%"

# ── Dashboard ───────────────────────────────────────────────────────

proc printDashboard*() =
  ## Print a full progress dashboard to stdout
  let saved = loadProgress()
  var totalLessons = 0
  var doneLessons = 0

  # First pass: count totals across all levels/chapters
  for level in levels:
    for chapter in level.chapters:
      for l in chapter.lessons:
        totalLessons.inc
        if l.id in saved:
          doneLessons.inc

  # ── Header ──
  echo ""
  echo bold("  ╔══════════════════════════════════════════════════════════════╗")
  echo bold("  ║") & "          " & bold("nimlings") & " — Interactive Nim Tutor           " & bold("║")
  echo bold("  ╚══════════════════════════════════════════════════════════════╝")
  echo ""

  # ── Daily streak ──
  let daily = loadDaily()
  if daily.streak > 0:
    let fire = "🔥"
    echo "    " & fire & " " & bold("Streak:") & " " & bold($daily.streak & " days")
    if daily.lessonsToday > 0:
      echo "    " & dim("  Today: " & $daily.lessonsToday & " lesson(s) done")
    else:
      echo "    " & dim("  No lesson yet today — run ") & bold("nimlings learn") & dim(" now")
  else:
    echo "    " & dim("  Start your streak: ") & bold("nimlings learn")
  echo ""

  # ── Overall progress ──
  echo "    " & bold("Overall Progress") & "   " & $doneLessons & "/" & $totalLessons & " lessons"
  echo "    " & progressBar(doneLessons, totalLessons, 50)
  echo ""

  # ── Levels ──
  echo "    " & bold("Levels") & "\n"

  for level in levels:
    var lvlDone = 0
    var lvlTotal = 0
    for chapter in level.chapters:
      for l in chapter.lessons:
        lvlTotal.inc
        if l.id in saved:
          lvlDone.inc

    echo "    " & bold("Level " & $level.id & ": " & level.name) & dim("  (" & $lvlDone & "/" & $lvlTotal & ")")
    echo "    " & progressBar(lvlDone, lvlTotal, 50)
    echo ""

    for chapter in level.chapters:
      var chDone = 0
      var chTotal = 0
      for l in chapter.lessons:
        chTotal.inc
        if l.id in saved:
          chDone.inc

      let status = if chDone == chTotal: bold(Green & "✓" & Reset)
                   elif chDone > 0: bold(Yellow & "⟳" & Reset)
                   else: bold(Grey & "○" & Reset)
      echo "      " & status & " " & bold(chapter.name) & dim("  (" & $chDone & "/" & $chTotal & ")")

      for l in chapter.lessons:
        let unlocked = l.id in saved or canSkip(l, saved)
        let marker = if l.id in saved: Green & "◆" & Reset
                     elif unlocked: Grey & "◇" & Reset
                     else: Red & "◇" & Reset
        let nameStr = if unlocked: l.name else: dim(l.name)
        echo "        " & marker & " " & l.id & ": " & nameStr

      echo ""

  # ── Next lesson ──
  var nextLesson: Lesson
  var foundNext = false
  for level in levels:
    for chapter in level.chapters:
      for l in chapter.lessons:
        if l.id notin saved:
          nextLesson = l
          foundNext = true
          break
      if foundNext: break
    if foundNext: break

  if foundNext:
    echo "    " & bold("Next up:") & " " & nextLesson.id & ": " & nextLesson.name
    echo "    " & dim("  ► nimlings watch " & nextLesson.id)
  else:
    echo "    " & bold(Green & "🎉 All lessons complete!" & Reset)
  echo ""

proc printLessonHeader*(lesson: Lesson) =
  ## Print a compact lesson header for watch mode
  echo ""
  echo bold("  ══════════════════════════════════════════════════════════════")
  echo "   " & bold(lesson.id) & ": " & bold(lesson.name)
  let firstLine = if lesson.conceptText.len > 0: lesson.conceptText.splitLines()[0] else: ""
  echo dim("   " & firstLine)
  echo ""
  echo "   " & bold("Task:") & " " & lesson.task
  echo "   " & dim("Edit: exercises/" & lesson.id.replace(".", "_") & "/" & lesson.filename)
  echo bold("  ══════════════════════════════════════════════════════════════")
  echo ""

proc printOutput*(msg: string) =
  ## Print validation output with color coding
  for line in msg.splitLines():
    let lower = line.toLowerAscii()
    if line.startsWith("Error") or "error" in lower:
      echo "  " & Red & line & Reset
    elif line.startsWith("Correct") or "success" in lower:
      echo "  " & Green & Bold & line & Reset
    elif line.startsWith("FAILED") or "failed" in lower:
      echo "  " & Red & Bold & line & Reset
    elif line.startsWith("Hint") or line.startsWith("---"):
      echo "  " & Cyan & line & Reset
    elif line.startsWith("Waiting") or line.startsWith("[DETECTED"):
      echo dim("  " & line)
    else:
      echo "  " & line
  echo ""

proc printSuccess*(lesson: Lesson) =
  ## Print success banner when a lesson is completed
  echo ""
  echo "  " & Green & Bold & "  ── ✅ " & lesson.id & " Complete! ──" & Reset
  echo ""

proc printError*(msg: string) =
  echo "  " & Red & Bold & "✗ " & Reset & msg
