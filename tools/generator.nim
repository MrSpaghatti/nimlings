import json, strutils, strformat, os, tables

const LessonFile = "src/lessons.json"

proc main() =
  let jsonContent = readFile(LessonFile)
  let modulesJson = parseJson(jsonContent)

  echo "import json, tables, strutils"
  echo "import types"
  echo ""
  echo "var modules*: seq[Module]"
  echo ""
  echo "proc initLessons*() ="
  echo "  modules = @[]"
  echo "  var m_lessons: seq[Lesson]"
  echo ""

  for module in modulesJson:
    echo "  m_lessons = @[]"
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
      val_code = val_code.replace(".strip()", ".strip()")
      val_code = val_code.replace("result.returncode", "exitCode")
      val_code = val_code.replace(" in code", " in code")
      val_code = val_code.replace(".replace(\"_\", \"\")", ".replace(\"_\", \"\")")
      val_code = val_code.replace(" and ", " and ").replace(" or ", " or ")

      let proc_name = fmt"validate_{id_safe}"
      echo fmt"  proc {proc_name}(code: string, output: string, stderr: string, exitCode: int): bool ="
      echo fmt"    return {val_code}"

      # Files handling
      var files_nim = "initTable[string, string]()"
      if lesson.hasKey("files") and lesson["files"].len > 0:
        var pairs: seq[string] = @[]
        for k, v in lesson["files"].pairs:
           # k is string, v is JsonNode (string)
           # We use & concatenation instead of fmt inside loop to be safe
           pairs.add(k.escapeJson & ": " & $v)
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

      echo "  m_lessons.add(Lesson("
      echo "    id: " & $lesson["id"] & ","
      echo "    name: " & $lesson["name"] & ","
      echo "    conceptText: " & $lesson["concept"] & ","
      echo "    task: " & $lesson["task"] & ","
      echo "    solution: " & solution & ","
      echo "    hint: " & hint & ","
      echo "    filename: " & filename & ","
      echo "    files: " & files_nim & ","
      echo "    cmd: " & cmd & ","
      echo "    compilerArgs: " & comp_args & ","
      echo "    skipRun: " & skipRun & ","
      echo "    validate: " & proc_name
      echo "  ))"

    echo "  modules.add(Module(name: " & $module["module"] & ", lessons: m_lessons))"

main()
