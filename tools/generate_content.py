
import json

# ... (LESSONS list from previous step is assumed to be here, but for brevity I will read it from the src/lessons.json I just created)

import json

with open("src/lessons.json", "r") as f:
    modules = json.load(f)

print("import json, tables, strutils")
print("import types")

print("var modules*: seq[Module]")

print("proc initLessons*() =")
print("  modules = @[]")
print("  var m_lessons: seq[Lesson]")

for module in modules:
    print(f"  m_lessons = @[]")
    for lesson in module["lessons"]:
        id_safe = lesson['id'].replace(".", "_")

        # Translate validation logic from Python-ish string to Nim
        val_code = lesson.get('validation_code', 'true')
        val_code = val_code.replace("result.stdout", "output")
        val_code = val_code.replace("result.stderr", "stderr")
        val_code = val_code.replace("result.exitCode", "exitCode")
        val_code = val_code.replace(".strip()", ".strip()")
        val_code = val_code.replace("result.returncode", "exitCode")
        val_code = val_code.replace(" in code", " in code")
        val_code = val_code.replace(".replace(\"_\", \"\")", ".replace(\"_\", \"\")")
        val_code = val_code.replace(" and ", " and ").replace(" or ", " or ")

        proc_name = f"validate_{id_safe}"
        print(f"  proc {proc_name}(code: string, output: string, stderr: string, exitCode: int): bool =")
        print(f"    return {val_code}")

        files_nim = "initTable[string, string]()"
        if "files" in lesson and lesson["files"]:
            files_nim = "{"
            pairs = []
            for k, v in lesson["files"].items():
                # Use json.dumps to get a properly escaped string literal (including quotes)
                # json.dumps("foo") -> "foo"
                pairs.append(f"{json.dumps(k)}: {json.dumps(v)}")
            files_nim += ", ".join(pairs) + "}.toTable"

        comp_args = "@[]"
        if "compiler_args" in lesson:
            items = [json.dumps(x) for x in lesson["compiler_args"]]
            comp_args = "@[" + ", ".join(items) + "]"

        # Use json.dumps to safely represent the string literal in Nim source code
        # json.dumps returns "string" (with quotes), so we don't need to add extra quotes

        print(f"  m_lessons.add(Lesson(")
        print(f"    id: {json.dumps(lesson['id'])},")
        print(f"    name: {json.dumps(lesson['name'])},")
        print(f"    conceptText: {json.dumps(lesson['concept'])},")
        print(f"    task: {json.dumps(lesson['task'])},")
        print(f"    solution: {json.dumps(lesson.get('solution', ''))},")
        print(f"    hint: {json.dumps(lesson.get('hint', ''))},")
        print(f"    filename: {json.dumps(lesson.get('filename', 'solution.nim'))},")
        print(f"    files: {files_nim},")
        print(f"    cmd: {json.dumps(lesson.get('cmd', 'c'))},")
        print(f"    compilerArgs: {comp_args},")
        print(f"    skipRun: {str(lesson.get('skip_run', False)).lower()},")
        print(f"    validate: {proc_name}")
        print(f"  ))")

    print(f"  modules.add(Module(name: {json.dumps(module['module'])}, lessons: m_lessons))")
