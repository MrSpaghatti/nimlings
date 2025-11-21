
import os, osproc, strutils, tables
import std/tempfiles
import types, models

const ExercisesDir = "exercises"

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

  # Build Command
  var cmd = "nim " & lesson.cmd
  if lesson.cmd == "c":
    cmd.add " -r --threads:on --hints:off"

  for arg in lesson.compilerArgs:
    cmd.add " " & arg

  cmd.add " " & quoteShell(lesson.filename)

  if lesson.cmd == "js":
    # For JS, we compile then run with node
    # TODO: Implement JS run logic (compile to .js then node)
    # For now, just compile
    cmd.add " -o:" & quoteShell(changeFileExt(lesson.filename, "js"))

  # Execute
  # We execute in the temp dir
  let (outp, errC) = execCmdEx(cmd, workingDir = tmpDir)

  # Simple execCmdEx for now
  return RunResult(stdout: outp, stderr: "", exitCode: errC)

proc validate*(lesson: Lesson, code: string, res: RunResult): (bool, string) =
  if res.exitCode != 0:
    return (false, "\n--- COMPILE/RUN ERROR ---\n" & res.stdout & "\n" & res.stderr & "\n\nHINT: " & lesson.hint)

  if lesson.validate(code, res.stdout, res.stderr, res.exitCode):
    return (true, "\nCorrect!\n" & res.stdout)
  else:
    return (false, "\n--- LOGIC ERROR ---\nOutput:\n" & res.stdout)

proc checkNimInstalled*() =
  if execCmd("nim --version") != 0:
    echo "Error: Nim compiler not found."
    quit(1)
