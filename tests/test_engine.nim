
import unittest, strutils, os
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

  test "runWithTimeout captures all output":
    # This test is designed to fail with the old, racy implementation of runWithTimeout.
    # It runs a command that produces a predictable amount of output and checks if it's all there.
    let tempScriptPath = "tests/temp_script_for_test.nim"
    let scriptContent = "for i in 1..5: echo \"line \", i"
    writeFile(tempScriptPath, scriptContent)
    defer: removeFile(tempScriptPath)

    let cmd = "nim e --hints:off --warnings:off " & tempScriptPath
    let (output, exitCode) = runWithTimeout(cmd, "")
    check exitCode == 0
    let expectedLines = 5
    # Nim's splitLines includes the empty line after the last newline, so we subtract 1
    let actualLines = output.splitLines.len - 1
    check actualLines == expectedLines
