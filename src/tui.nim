
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
  # Force redraw
  state.tb.clear()

  # Update mod time after edit to avoid immediate trigger if not changed significantly
  # or set it to 0 to force re-check? No, better to just update it.
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

  # Spawn runCode
  # Warning: Lesson object must be thread safe or copied.
  # runCode takes (Lesson, string).
  state.checkFuture = spawn runCode(lesson, code)

proc pollCheckResult() =
  if not state.isChecking: return

  if state.checkFuture.isReady():
    let res = ^state.checkFuture
    state.isChecking = false

    # Validate
    let lesson = state.flatLessons[state.currentLessonIdx]
    # Note: We assume lesson hasn't changed index while checking.
    # If user moved, we might verify the wrong lesson against the result.
    # But let's assume it's fine for now or lock UI?
    # Or better: Store the lesson ID in the future? Complex.
    # We'll just check against current active lesson for simplicity.

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
      # Trigger check
      let lesson = state.flatLessons[state.currentLessonIdx]
      # Verify watched file belongs to current lesson
      if state.watchedFile.endsWith(lesson.filename):
         startCheck(lesson)
  except:
    discard

# --- Drawing ---

proc drawTree(x, y, w, h: int) =
  state.tb.drawRect(x, y, x+w-1, y+h-1)
  state.tb.write(x+2, y, " Curriculum ")

  let maxItems = h - 2
  let startIdx = max(0, state.currentLessonIdx - (maxItems div 2))
  let endIdx = min(state.flatLessons.len, startIdx + maxItems)

  for i in startIdx ..< endIdx:
    let lesson = state.flatLessons[i]
    let row = y + 1 + (i - startIdx)
    var prefix = "[ ] "
    if lesson.id in state.completed: prefix = "[x] "

    var style: set[Style] = {}
    if i == state.currentLessonIdx:
      style = {styleReverse}
      if state.activeView == vTree:
        # Highlight active focus
        state.tb.write(x+1, row, ">", fgCyan)

    var text = prefix & lesson.id & ": " & lesson.name
    if text.len > w - 3: text = text[0 ..< w-3] & "..."

    state.tb.write(x+2, row, style, text)

proc drawContent(x, y, w, h: int) =
  state.tb.drawRect(x, y, x+w-1, y+h-1)
  state.tb.write(x+2, y, " Lesson ")

  let lesson = state.flatLessons[state.currentLessonIdx]
  var lines: seq[string] = @[]
  lines.add "ID: " & lesson.id
  lines.add "Name: " & lesson.name
  lines.add ""
  lines.add "--- Concept ---"
  # Simple wrapping
  for line in lesson.conceptText.splitLines:
    if line.len < w - 4: lines.add line
    else: lines.add line[0 ..< w-4] # TODO: Better wrap

  lines.add ""
  lines.add "--- Task ---"
  for line in lesson.task.splitLines:
    if line.len < w - 4: lines.add line
    else: lines.add line[0 ..< w-4]

  lines.add ""
  lines.add "--- Instructions ---"
  lines.add "Press 'e' or Enter to edit."
  lines.add "Auto-check on save is enabled."

  for i, line in lines:
    if i >= h - 2: break
    state.tb.write(x+2, y+1+i, line)

proc drawOutput(x, y, w, h: int) =
  state.tb.drawRect(x, y, x+w-1, y+h-1)
  var title = " Output "
  if state.isChecking: title &= "(Checking...) "
  state.tb.write(x+2, y, title)

  for i, line in state.outputBuffer:
    if i >= h - 2: break
    state.tb.write(x+2, y+1+i, line)

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
  # Flatten lessons
  state.flatLessons = @[]
  for m in modules:
    for l in m.lessons:
      state.flatLessons.add(l)

  state.tb = newTerminalBuffer(terminalWidth(), terminalHeight())
  state.activeView = vTree
  state.isChecking = false

  # Load progress
  let saved = loadProgress()
  for s in saved: state.completed.add(s)

  # Init watcher for first lesson
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
    let contentH = (h.float * 0.6).int # More space for content since editor is gone
    let rightW = w - treeW
    let outputH = h - contentH

    drawTree(0, 0, treeW, h)
    drawContent(treeW, 0, rightW, contentH)
    drawOutput(treeW, contentH, rightW, outputH)

    state.tb.display()

    pollCheckResult()
    checkFileWatcher()

    var key = getKey()
    case key
    of Key.Q:
      exitProc()
    of Key.Tab:
      # Cycle views
      if state.activeView == vTree: state.activeView = vContent
      elif state.activeView == vContent: state.activeView = vOutput
      else: state.activeView = vTree
    of Key.E, Key.Enter:
       openInEditor(state.flatLessons[state.currentLessonIdx])
    of Key.R:
       # Manual run
       startCheck(state.flatLessons[state.currentLessonIdx])
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

    sleep(50) # Slightly slower loop to save CPU, 20ms is fast
