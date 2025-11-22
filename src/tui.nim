
import illwill, os, strutils, times, std/sets, osproc, threadpool
import types, content, models, engine

# Constants
const
  KEY_ESC = Key.Escape
  KEY_TAB = Key.Tab
  KEY_ENTER = Key.Enter

type
  View = enum
    vTree, vContent, vOutput

  AppState = object
    tb: TerminalBuffer
    currentLessonIdx: int
    activeView: View
    showHelp: bool
    outputBuffer: seq[string]

    # Async State
    checkFuture: FlowVar[RunResult]
    isChecking: bool
    lastModTime: Time
    watchedFile: string

    # Tree State
    flatLessons: seq[Lesson]
    completed: seq[string] # IDs

var state: AppState

# --- Actions ---

proc openInEditor(lesson: Lesson) =
  # Ensure file exists on disk
  let path = ensureLessonFile(lesson)

  # Update watched file
  state.watchedFile = path
  try:
    state.lastModTime = getLastModificationTime(path)
  except:
    state.lastModTime = fromUnix(0)

  # Get EDITOR from env
  var editor = getEnv("EDITOR")
  if editor == "":
    if findExe("vim") != "": editor = "vim"
    elif findExe("nano") != "": editor = "nano"
    elif findExe("code") != "": editor = "code"
    else:
      state.outputBuffer = @["Error: EDITOR environment variable not set."]
      return

  # Suspend TUI, run editor, restore TUI
  illwillDeinit()
  showCursor()

  discard execCmd(editor & " " & quoteShell(path))

  # Restore
  illwillInit(fullscreen=true)
  hideCursor()
  state.tb = newTerminalBuffer(terminalWidth(), terminalHeight())

  # FORCE FULL REDRAW sequence to fix ghosting/blank screens
  # 1. Clear internal buffer to spaces
  state.tb.clear()
  # 2. Write the empty buffer to screen. This forces illwill to diff (Current Garbage) vs (Empty),
  #    emitting ANSI clear codes for the whole screen.
  state.tb.display()

  # 3. Main loop will now draw UI on top of this known empty state.

  try:
    state.lastModTime = getLastModificationTime(path)
  except:
    discard

proc startCheck(lesson: Lesson) =
  if state.isChecking: return

  let path = ensureLessonFile(lesson)
  let code = readFile(path)

  state.outputBuffer = @["Checking..."]
  state.isChecking = true

  state.checkFuture = spawn runCode(lesson, code)

proc showHint(lesson: Lesson) =
  # Append the hint to the output buffer
  state.outputBuffer = @["--- HINT ---", lesson.hint, ""]

proc pollCheckResult() =
  if not state.isChecking: return

  if state.checkFuture.isReady():
    let res = ^state.checkFuture
    state.isChecking = false

    let lesson = state.flatLessons[state.currentLessonIdx]
    let path = ensureLessonFile(lesson)
    let code = readFile(path)

    let (success, msg) = validate(lesson, code, res)
    state.outputBuffer = msg.splitLines()

    if success:
      var p = loadProgress()
      p.incl(lesson.id)
      saveProgress(p)
      if lesson.id notin state.completed: state.completed.add(lesson.id)

proc checkFileWatcher() =
  if state.watchedFile == "" or not fileExists(state.watchedFile): return

  try:
    let t = getLastModificationTime(state.watchedFile)
    if t > state.lastModTime:
      state.lastModTime = t
      let lesson = state.flatLessons[state.currentLessonIdx]
      if state.watchedFile.endsWith(lesson.filename):
         startCheck(lesson)
  except:
    discard

# --- Drawing ---

proc drawTree(x, y, w, h: int) =
  # Reset style for the box
  state.tb.fill(x, y, x+w-1, y+h-1, " ")
  state.tb.drawRect(x, y, x+w-1, y+h-1)
  state.tb.write(x+2, y, " Curriculum ", fgYellow)

  let maxItems = h - 2
  let startIdx = max(0, state.currentLessonIdx - (maxItems div 2))
  let endIdx = min(state.flatLessons.len, startIdx + maxItems)

  for i in startIdx ..< endIdx:
    let lesson = state.flatLessons[i]
    let row = y + 1 + (i - startIdx)
    var prefix = "[ ] "
    var color = fgWhite
    if lesson.id in state.completed:
      prefix = "[x] "
      color = fgGreen

    var style: set[Style] = {}
    if i == state.currentLessonIdx:
      style = {styleReverse}
      if state.activeView == vTree:
        state.tb.write(x+1, row, ">", fgCyan)

    var text = prefix & lesson.id & ": " & lesson.name
    if text.len > w - 3: text = text[0 ..< w-3] & "..."

    state.tb.write(x+2, row, color, style, text, resetStyle)

proc drawContent(x, y, w, h: int) =
  state.tb.fill(x, y, x+w-1, y+h-1, " ")
  state.tb.drawRect(x, y, x+w-1, y+h-1)
  state.tb.write(x+2, y, " Lesson ", fgYellow)

  let lesson = state.flatLessons[state.currentLessonIdx]
  var lines: seq[(string, ForegroundColor)] = @[]
  lines.add ("ID: " & lesson.id, fgCyan)
  lines.add ("Name: " & lesson.name, fgWhite)
  lines.add ("", fgWhite)
  lines.add ("--- Concept ---", fgYellow)

  for line in lesson.conceptText.splitLines:
    if line.len < w - 4: lines.add (line, fgWhite)
    else: lines.add (line[0 ..< w-4], fgWhite)

  lines.add ("", fgWhite)
  lines.add ("--- Task ---", fgYellow)
  for line in lesson.task.splitLines:
    if line.len < w - 4: lines.add (line, fgWhite)
    else: lines.add (line[0 ..< w-4], fgWhite)

  lines.add ("", fgWhite)
  lines.add ("--- Instructions ---", fgYellow)
  lines.add ("'e': edit  'r': run  'h': hint", fgWhite)
  lines.add ("Auto-check on save is enabled.", fgWhite)

  for i, (text, color) in lines:
    if i >= h - 2: break
    state.tb.write(x+2, y+1+i, color, text, resetStyle)

proc drawOutput(x, y, w, h: int) =
  state.tb.fill(x, y, x+w-1, y+h-1, " ")
  state.tb.drawRect(x, y, x+w-1, y+h-1)
  var title = " Output "
  if state.isChecking: title &= "(Checking...) "

  var titleColor = fgYellow
  if state.isChecking: titleColor = fgMagenta

  state.tb.write(x+2, y, titleColor, title)

  for i, line in state.outputBuffer:
    if i >= h - 2: break
    var color = fgWhite
    if "Error" in line or "failed" in line.toLowerAscii: color = fgRed
    elif "Success" in line or "Correct" in line: color = fgGreen
    elif "Hint" in line: color = fgCyan

    state.tb.write(x+2, y+1+i, color, line, resetStyle)

# --- Main ---

proc exitProc() =
  illwillDeinit()
  showCursor()
  quit(0)

proc runTUI*() =
  illwillInit(fullscreen=true)
  setControlCHook(proc() {.noconv.} = exitProc())
  hideCursor()

  initLessons()
  state.flatLessons = @[]
  for m in modules:
    for l in m.lessons:
      state.flatLessons.add(l)

  state.tb = newTerminalBuffer(terminalWidth(), terminalHeight())
  state.activeView = vTree
  state.isChecking = false

  let saved = loadProgress()
  for s in saved: state.completed.add(s)

  if state.flatLessons.len > 0:
    let l = state.flatLessons[state.currentLessonIdx]
    let path = ensureLessonFile(l)
    state.watchedFile = path
    try: state.lastModTime = getLastModificationTime(path)
    except: discard

  while true:
    state.tb.clear()
    let w = terminalWidth()
    let h = terminalHeight()

    let treeW = (w.float * 0.3).int
    let contentH = (h.float * 0.6).int
    let rightW = w - treeW
    let outputH = h - contentH

    drawTree(0, 0, treeW, h)
    drawContent(treeW, 0, rightW, contentH)
    drawOutput(treeW, contentH, rightW, outputH)

    state.tb.display()

    # Input Drain Loop
    while true:
      var key = getKey()
      if key == Key.None: break

      case key
      of Key.Q:
        exitProc()
      of Key.Tab:
        if state.activeView == vTree: state.activeView = vContent
        elif state.activeView == vContent: state.activeView = vOutput
        else: state.activeView = vTree
      of Key.E, Key.Enter:
         openInEditor(state.flatLessons[state.currentLessonIdx])
      of Key.R:
         startCheck(state.flatLessons[state.currentLessonIdx])
      of Key.H, Key.QuestionMark:
         showHint(state.flatLessons[state.currentLessonIdx])
      of Key.J, Key.Down:
        if state.activeView == vTree:
          state.currentLessonIdx = min(state.flatLessons.len - 1, state.currentLessonIdx + 1)
          # Update watcher
          let l = state.flatLessons[state.currentLessonIdx]
          let path = ensureLessonFile(l)
          state.watchedFile = path
          try: state.lastModTime = getLastModificationTime(path)
          except: discard
      of Key.K, Key.Up:
        if state.activeView == vTree:
          state.currentLessonIdx = max(0, state.currentLessonIdx - 1)
          # Update watcher
          let l = state.flatLessons[state.currentLessonIdx]
          let path = ensureLessonFile(l)
          state.watchedFile = path
          try: state.lastModTime = getLastModificationTime(path)
          except: discard
      else: discard

    # Logic Updates
    pollCheckResult()
    checkFileWatcher()

    sleep(20) # Low sleep for responsiveness
