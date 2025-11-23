import json, strutils, strformat, os, tables

const LessonFile = "src/lessons.json"
const OutputFile = "src/content.nim"

proc main() =
  if not fileExists(LessonFile):
    quit("Error: " & LessonFile & " not found!")

  let jsonContent = readFile(LessonFile)
  var modulesJson: JsonNode
  try:
    modulesJson = parseJson(jsonContent)
  except JsonParsingError as e:
    quit("Error: Invalid JSON in " & LessonFile & " - " & e.msg)

  var output = newSeq[string]()

  output.add "import json, tables, strutils"
  output.add "import types"
  output.add ""
  output.add "var modules*: seq[Module]"
  output.add ""
  output.add "proc initLessons*() ="
  output.add "  modules = @[]"
  output.add "  var m_lessons: seq[Lesson]"
  output.add ""

  for module in modulesJson:
    output.add "  m_lessons = @[]"
    let lessons = module["lessons"]
    for lesson in lessons:
      let id = lesson["id"].getStr()
      let id_safe = id.replace(".", "_")

      # Validation logic translation
      var val_code = "true"
      if lesson.hasKey("validation_code"):
        val_code = lesson["validation_code"].getStr()

      val_code = val_code.replace("result.stdout", "output")
      val_code = val_code.replace("result.stderr", "stderr")
      val_code = val_code.replace("result.exitCode", "exitCode")
      val_code = val_code.replace("result.returncode", "exitCode")

      let proc_name = fmt"validate_{id_safe}"
      output.add fmt"  proc {proc_name}(code: string, output: string, stderr: string, exitCode: int): bool ="
      output.add fmt"    return {val_code}"

      # Files handling
      var files_nim = "initTable[string, string]()"
      if lesson.hasKey("files") and lesson["files"].len > 0:
        var pairs: seq[string] = @[]
        for k, v in lesson["files"].pairs:
           # k is a string key, v is a JsonNode value
           # $ %k produces a quoted JSON key, $v produces the JSON value
           pairs.add(($ %k) & ": " & $v)
        files_nim = "{" & pairs.join(", ") & "}.toTable"

      # Compiler args
      var comp_args = "@[]"
      if lesson.hasKey("compiler_args"):
        var items: seq[string] = @[]
        for item in lesson["compiler_args"]:
          # item is JsonNode (string)
          items.add($item)
        comp_args = "@[" & items.join(", ") & "]"

      let solution = if lesson.hasKey("solution"): $lesson["solution"] else: "\"\""
      let hint = if lesson.hasKey("hint"): $lesson["hint"] else: "\"\""
      let filename = if lesson.hasKey("filename"): $lesson["filename"] else: "\"solution.nim\""
      let cmd = if lesson.hasKey("cmd"): $lesson["cmd"] else: "\"c\""

      var skipRun = "false"
      if lesson.hasKey("skip_run"):
        skipRun = $lesson["skip_run"].getBool()

      output.add "  m_lessons.add(Lesson("
      output.add "    id: " & $lesson["id"] & ","
      output.add "    name: " & $lesson["name"] & ","
      output.add "    conceptText: " & $lesson["concept"] & ","
      output.add "    task: " & $lesson["task"] & ","
      output.add "    solution: " & solution & ","
      output.add "    hint: " & hint & ","
      output.add "    filename: " & filename & ","
      output.add "    files: " & files_nim & ","
      output.add "    cmd: " & cmd & ","
      output.add "    compilerArgs: " & comp_args & ","
      output.add "    skipRun: " & skipRun & ","
      output.add "    validate: " & proc_name
      output.add "  ))"

    output.add "  modules.add(Module(name: " & $module["module"] & ", lessons: m_lessons))"

  try:
    writeFile(OutputFile, output.join("\n"))
  except OSError as e:
    quit("Error: Failed to write to " & OutputFile & ": " & e.msg)

main()
