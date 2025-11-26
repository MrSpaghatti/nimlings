
import unittest, strutils
import types, engine

suite "Engine":

  test "Validation Logic":
    # We can't easily test 'validate' because it requires a 'Lesson' object with a specific 'validate' proc attached.
    # However, we can test the 'validate' wrapper in engine.nim given a mock Lesson.

    # Create a mock lesson with a mock validator
    var l = Lesson(
      id: "test",
      hint: "Try harder",
      validate: proc(c, o, e: string, x: int): bool = return x == 0
    )

    # Test Success
    let resSuccess = RunResult(stdout: "ok", stderr: "", exitCode: 0)
    let (ok1, msg1) = validate(l, "code", resSuccess)
    check ok1 == true
    check "Correct" in msg1

    # Test Failure (Exit Code)
    let resFailExit = RunResult(stdout: "err", stderr: "bad", exitCode: 1)
    let (ok2, msg2) = validate(l, "code", resFailExit)
    check ok2 == false
    check "COMPILE/RUN ERROR" in msg2
    check "Try harder" in msg2

    # Test Failure (Logic)
    var l2 = Lesson(
      id: "test2",
      hint: "",
      validate: proc(c, o, e: string, x: int): bool = return o == "expected"
    )
    let resFailLogic = RunResult(stdout: "wrong", stderr: "", exitCode: 0)
    let (ok3, msg3) = validate(l2, "code", resFailLogic)
    check ok3 == false
    check "LOGIC ERROR" in msg3

  test "JS Runner":
    var l = Lesson(
      id: "js_test",
      filename: "test.nim",
      cmd: "js"
    )
    let code = "echo \"Hello from JS\""
    let res = runCode(l, code)
    check res.exitCode == 0
    check "Hello from JS" in res.stdout

  test "JS Runner Compilation Failure":
    var l = Lesson(
      id: "js_fail_test",
      filename: "test.nim",
      cmd: "js"
    )
    let code = "echo \"Hello from JS" # Intentional syntax error
    let res = runCode(l, code)
    check res.exitCode != 0

  test "Project Runner":
    var l = Lesson(
      id: "proj_test",
      filename: "src/main.nim",
      lessonType: "project",
      files: {
        "proj_test.nimble": "version = \"0.1.0\"\nauthor = \"Tester\"\ndescription = \"A test\"\nlicense = \"MIT\"\n\ntask test, \"Run tests\":\n  exec \"nim c -r src/main.nim\"",
        "src/main.nim": "echo \"Hello from Project\""
      }.toTable
    )
    let code = "echo \"This is the main file content\"" # This is the content of src/main.nim
    let res = runCode(l, code)
    check res.exitCode == 0
    check "Hello from Project" in res.stdout
