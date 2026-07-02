import json, strutils, strformat, os

const LessonFile = "src/lessons.json"
const OutputFile = "src/content.nim"

proc main() =
  if not fileExists(LessonFile):
    quit("Error: " & LessonFile & " not found!")

  let jsonContent = readFile(LessonFile)
  var root: JsonNode
  try:
    root = parseJson(jsonContent)
  except JsonParsingError as e:
    quit("Error: Invalid JSON in " & LessonFile & " - " & e.msg)

  var output = newSeq[string]()

  output.add "import tables, strutils"
  output.add "import types"
  output.add ""
  output.add "var levels*: seq[Level]"
  output.add ""
  output.add "proc initLessons*() ="
  output.add "  levels = @[]"
  output.add "  var ch_lessons: seq[Lesson]"
  output.add "  var chapters: seq[Chapter]"
  output.add ""

  for level in root["levels"]:
    let levelId = level["id"].getInt()
    output.add "  chapters = @[]"
    output.add ""

    for chapter in level["chapters"]:
      output.add "  ch_lessons = @[]"

      for lesson in chapter["lessons"]:
        let id = lesson["id"].getStr()
        let id_safe = id.replace(".", "_")

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

        var files_nim = "initTable[string, string]()"
        if lesson.hasKey("files") and lesson["files"].len > 0:
          var pairs: seq[string] = @[]
          for k, v in lesson["files"].pairs:
             pairs.add(($ %k) & ": " & $v)
          files_nim = "{" & pairs.join(", ") & "}.toTable"

        var comp_args = "@[]"
        if lesson.hasKey("compiler_args"):
          var items: seq[string] = @[]
          for item in lesson["compiler_args"]:
            items.add($item)
          comp_args = "@[" & items.join(", ") & "]"

        var run_args = "@[]"
        if lesson.hasKey("args"):
          var items: seq[string] = @[]
          for item in lesson["args"]:
            items.add($item)
          run_args = "@[" & items.join(", ") & "]"

        let solution = if lesson.hasKey("solution"): $lesson["solution"] else: "\"\""
        let hint = if lesson.hasKey("hint"): $lesson["hint"] else: "\"\""
        let filename = if lesson.hasKey("filename"): $lesson["filename"] else: "\"solution.nim\""
        let cmd = if lesson.hasKey("cmd"): $lesson["cmd"] else: "\"c\""
        let lType = if lesson.hasKey("type"): $lesson["type"] else: "\"single_file\""

        var skipRun = "false"
        if lesson.hasKey("skip_run"):
          skipRun = $lesson["skip_run"].getBool()

        let difficulty = if lesson.hasKey("difficulty"): $lesson["difficulty"] else: "\"easy\""

        var prerequisites_nim = "@[]"
        if lesson.hasKey("prerequisites"):
          var items: seq[string] = @[]
          for item in lesson["prerequisites"]:
            items.add($item)
          prerequisites_nim = "@[" & items.join(", ") & "]"

        let crossNotes = if lesson.hasKey("cross_language_notes"): $lesson["cross_language_notes"] else: "\"\""
        let docRefs = if lesson.hasKey("docs") and lesson["docs"].len > 0:
          var items: seq[string] = @[]
          for item in lesson["docs"]:
            let title = if item.hasKey("title"): $item["title"] else: $item
            let url = if item.hasKey("url"): $item["url"] else: $item
            let summary = if item.hasKey("summary"): $item["summary"] else: "\"\""
            items.add("DocLink(title: " & title & ", url: " & url & ", summary: " & summary & ")")
          "@[" & items.join(", ") & "]"
        else:
          "newSeq[DocLink]()"

        output.add "  ch_lessons.add(Lesson("
        output.add "    id: " & $lesson["id"] & ","
        output.add "    name: " & $lesson["name"] & ","
        output.add "    conceptText: " & $lesson["concept"] & ","
        output.add "    task: " & $lesson["task"] & ","
        output.add "    solution: " & solution & ","
        output.add "    hint: " & hint & ","
        output.add "    filename: " & filename & ","
        output.add "    files: " & files_nim & ","
        output.add "    lessonType: " & lType & ","
        output.add "    cmd: " & cmd & ","
        output.add "    docs: " & docRefs & ","
        output.add "    compilerArgs: " & comp_args & ","
        output.add "    runArgs: " & run_args & ","
        output.add "    skipRun: " & skipRun & ","
        output.add "    difficulty: " & difficulty & ","
        output.add "    prerequisites: " & prerequisites_nim & ","
        output.add "    crossLanguageNotes: " & crossNotes & ","
        output.add "    validate: " & proc_name
        output.add "  ))"

      output.add "  chapters.add(Chapter(id: " & $chapter["id"] & ", name: " & $chapter["name"] & ", lessons: ch_lessons))"
      output.add ""

    output.add "  levels.add(Level(id: " & $levelId & ", name: " & $level["name"] & ", chapters: chapters))"
    output.add ""

  try:
    writeFile(OutputFile, output.join("\n"))
  except OSError as e:
    quit("Error: Failed to write to " & OutputFile & ": " & e.msg)

main()
