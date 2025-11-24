
import os, osproc, strutils, tables, streams, times, re
import std/tempfiles
import types, models

const ExercisesDir = "exercises"
const RunTimeout = 5000 # 5 seconds

# Regexes for common Nim errors
# Cannot be const because re() might involve C calls or checks not available at CT
let
  ReTypeMismatch = re"type mismatch: got <(.+)> but expected '(.+)'"
  ReIdentUndeclared = re"undeclared identifier: '(.+)'"
  ReIndentError = re"invalid indentation"

proc parseCompilerErrors(raw: string): string =
  var hints = newSeq[string]()

  if raw.contains(ReTypeMismatch):
    hints.add "Type Mismatch: You're trying to put a square peg in a round hole.\nCheck your types."

  if raw.contains(ReIdentUndeclared):
    hints.add "Undeclared Identifier: You used a name that doesn't exist.\nDid you typo it? Did you forget to declare it?"

  if raw.contains(ReIndentError):
    hints.add "Indentation Error: Nim uses whitespace to define blocks.\nAlign your code properly."

  if hints.len > 0:
    return raw & "\n\n--- HINTS ---\n" & hints.join("\n")

  return raw

proc getLessonPath(lesson: Lesson): string =
  # Clean ID for folder name
  let safeId = lesson.id.replace(".", "_")
  return ExercisesDir / safeId / lesson.filename

proc ensureLessonFile*(lesson: Lesson): string =
  let path = getLessonPath(lesson)
  if not fileExists(path):
    createDir(parentDir(path))

    # Create stub content
    var content = "# " & lesson.name & "\n"
    content.add "# Task: " & lesson.task.replace("\n", "\n# ") & "\n\n"

    # If there are project files, creating them here might be useful?
    # For now, just ensure the main file exists.

    writeFile(path, content)

  return absolutePath(path)

proc runWithTimeout(cmd: string, workingDir: string): tuple[output: string, exitCode: int] =
  # Use shell to run the command to handle arguments parsing automatically
  # On Unix: sh -c "cmd"
  # On Windows: cmd /c "cmd"
  let p = startProcess(cmd, workingDir = workingDir, options = {poStdErrToStdOut, poUsePath, poEvalCommand})
  defer: p.close()

  let t0 = epochTime()
  var output = ""
  var readStreams = @[p.outputStream]

  while p.running:
    if epochTime() - t0 > (RunTimeout / 1000.0):
      p.terminate()
      os.sleep(100)
      if p.running: p.kill()
      output.add(p.outputStream.readAll())
      return ("Error: Execution timed out (infinite loop?)\n" & output, 124)

    # Non-blocking read for POSIX-like systems
    when defined(posix):
      if p.hasData:
        var line = ""
        while p.outputStream.readLine(line):
          output.add(line & "\n")
    else:
      # Fallback for Windows - less efficient, small sleeps
      os.sleep(50)

  # Read remaining output
  if p.outputStream.atEnd == false:
    output.add(p.outputStream.readAll())
  return (output, p.peekExitCode())


proc runCode*(lesson: Lesson, code: string): RunResult =
  # Create temp dir
  let tmpDir = createTempDir("nimlings_", "")
  defer: removeDir(tmpDir) # Clean up

  # Write main file
  let mainFile = tmpDir / lesson.filename
  # Ensure parent dirs exist
  createDir(parentDir(mainFile))
  writeFile(mainFile, code)

  # Write project files
  for fname, content in lesson.files:
    let path = tmpDir / fname
    createDir(parentDir(path))
    writeFile(path, content)

  if lesson.skipRun:
    return RunResult(stdout: "", stderr: "", exitCode: 0)

  if lesson.cmd == "js":
    # JS-specific logic: compile, then run with Node
    let jsFile = tmpDir / changeFileExt(lesson.filename, "js")
    var compileCmd = "nim js -o:" & quoteShell(jsFile)
    for arg in lesson.compilerArgs:
      compileCmd.add " " & arg
    compileCmd.add " " & quoteShell(lesson.filename)

    let (compileOut, compileErr) = runWithTimeout(compileCmd, tmpDir)
    if compileErr != 0:
      return RunResult(stdout: compileOut, stderr: "", exitCode: compileErr)

    # If compilation is successful, run with node
    let runCmd = "node " & quoteShell(jsFile)
    let (runOut, runErr) = runWithTimeout(runCmd, tmpDir)
    return RunResult(stdout: runOut, stderr: "", exitCode: runErr)

  # Build Command for other targets
  var cmd = "nim " & lesson.cmd
  if lesson.cmd == "c":
    cmd.add " -r --threads:on --hints:off"

  for arg in lesson.compilerArgs:
    cmd.add " " & arg

  cmd.add " " & quoteShell(lesson.filename)

  # Execute
  let (outp, errC) = runWithTimeout(cmd, tmpDir)

  return RunResult(stdout: outp, stderr: "", exitCode: errC)

proc validate*(lesson: Lesson, code: string, res: RunResult): (bool, string) =
  if res.exitCode != 0:
    let friendlyErr = parseCompilerErrors(res.stdout & "\n" & res.stderr)
    return (false, "\n--- COMPILE/RUN ERROR ---\n" & friendlyErr & "\n\nHINT: " & lesson.hint)

  if lesson.validate(code, res.stdout, res.stderr, res.exitCode):
    return (true, "\nCorrect!\n" & res.stdout)
  else:
    return (false, "\n--- LOGIC ERROR ---\nOutput:\n" & res.stdout)

proc checkNimInstalled*() =
  if execCmd("nim --version") != 0:
    echo "Error: Nim compiler not found."
    quit(1)
