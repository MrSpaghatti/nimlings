# Nimlings Sandbox Module
#
# Responsible for executing user-submitted exercise code in a more controlled environment.
#
# CURRENT STATUS: THIS IS A PLACEHOLDER AND NOT A SECURE SANDBOX.
# The current implementation directly uses osproc, which offers no real security isolation.
# WASM path is a Proof-of-Concept.
#
# --- Research & Future Directions for True Sandboxing ---
# (Research notes from previous steps remain relevant)
#

import osproc
import os
import strutils

type RunResultFlag* = enum
  CompilationFailed,
  RuntimeFailed,
  ValidationFailed, # Note: This flag is set by the caller (runExercise), not directly here.
  Success

type SandboxedExecutionResult* = object
  flags*: set[RunResultFlag]
  compilationOutput*: string
  runtimeOutput*: string

proc executeWASM_PoC(filePath: string, exerciseDir: string): SandboxedExecutionResult =
  ## Proof-of-Concept for WASM execution.
  ## Attempts to compile to WASM. If successful, for this PoC, it runs the *original*
  ## .nim file via native compilation to get output for validation, as embedding a true
  ## WASM runtime and capturing its stdout is more involved for this stage.
  var res: SandboxedExecutionResult
  let nimexe = "nim"
  let wasmOutName = filePath.changeFileExt(".wasm")
  let wasmBuildLogFile = filePath.changeFileExt(".wasm_build.log")

  echo "Attempting WASM compilation for: ", filePath

  var p = startProcess(nimexe, args = ["compile", "--os:wasi", "--cpu:wasm32", "--out:" & wasmOutName, "--compileOnly", filePath],
                       options = {poStdErrToStdOut, poUsePath}, workingDir = exerciseDir)
  var outputLines: seq[string]
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  p.close()
  let wasmCompilationLog = outputLines.join("\n")
  writeFile(wasmBuildLogFile, wasmCompilationLog) # Save for inspection

  if p.peekExitCode() != 0:
    res.flags = {CompilationFailed}
    res.compilationOutput = "WASM Compilation Failed. See " & wasmBuildLogFile & "\n" & wasmCompilationLog
    if fileExists(wasmOutName): removeFile(wasmOutName)
    return res

  echo "WASM compilation successful: ", wasmOutName
  res.compilationOutput = "WASM Compilation Successful (Log: " & wasmBuildLogFile & ").\n" &
                          "PoC Note: Runtime output below is from NATIVE execution of the source for validation purposes.\n"

  # PoC Limitation: Run original .nim file natively to get output.
  # This section duplicates parts of the native execution logic.
  let tempExeName = filePath.changeFileExt(".exe_temp_poc_native_run")
  var nativeCompileProc = startProcess(nimexe, args = ["compile", "--hints:off", "--verbosity:0", "--out:" & tempExeName, filePath],
                                       options = {poStdErrToStdOut, poUsePath}, workingDir = exerciseDir)
  outputLines = @[] # Reset for native compile output
  while nativeCompileProc.running():
    if nativeCompileProc.peekExitCode != -1: break
    var line = nativeCompileProc.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  nativeCompileProc.close()
  res.compilationOutput &= "Native compilation log for PoC output: \n" & outputLines.join("\n")

  if nativeCompileProc.peekExitCode() != 0:
    res.flags = {CompilationFailed} # Native compilation part of PoC failed
    if fileExists(wasmOutName): removeFile(wasmOutName)
    if fileExists(tempExeName): removeFile(tempExeName)
    return res

  if not fileExists(tempExeName):
     res.flags = {CompilationFailed}
     res.compilationOutput &= "\nPoC Fallback: Native compiled executable not found."
     if fileExists(wasmOutName): removeFile(wasmOutName)
     return res

  var nativeRunProc = startProcess(tempExeName, args = [],
                                   options = {poUsePath, poStdErrToStdOut}, workingDir = exerciseDir)
  outputLines = @[] # Reset for runtime output
  while nativeRunProc.running():
    if nativeRunProc.peekExitCode != -1: break
    var line = nativeRunProc.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  nativeRunProc.close()
  res.runtimeOutput = outputLines.join("\n")

  if fileExists(tempExeName): removeFile(tempExeName)
  if fileExists(wasmOutName): removeFile(wasmOutName)

  if nativeRunProc.peekExitCode() != 0:
    res.flags = {RuntimeFailed} # Runtime error from the PoC's native execution
  else:
    res.flags = {Success} # WASM compile success + native run success for PoC

  return res

proc executeSandboxed*(
    filePath: string,
    exerciseDir: string,
    allowedReadPaths: seq[string] = @[],
    allowedWritePaths: seq[string] = @[],
    preference: string = "native"
  ): SandboxedExecutionResult =
  ## Executes the Nim code at filePath.
  ## Chooses execution path (native or WASM PoC) based on `preference`.
  ## WARNING: NATIVE PATH IS NOT SECURE. WASM PATH IS A PoC.

  if preference == "wasm":
    echo "Sandbox: WASM preference selected (Proof-of-Concept path)."
    return executeWASM_PoC(filePath, exerciseDir)

  # Default to native execution
  var res: SandboxedExecutionResult
  let nimexe = "nim"

  var p = startProcess(nimexe, args = ["check", filePath],
                       options = {poStdErrToStdOut, poUsePath}, workingDir = exerciseDir)
  var outputLines: seq[string]
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  p.close()

  res.compilationOutput = outputLines.join("\n")
  if p.peekExitCode() != 0:
    res.flags = {CompilationFailed}
    return res

  let tempExeName = filePath.changeFileExt(".exe_temp_sandbox")
  p = startProcess(nimexe, args = ["compile", "--hints:off", "--verbosity:0", "--out:" & tempExeName, filePath],
                   options = {poStdErrToStdOut, poUsePath}, workingDir = exerciseDir)
  outputLines = @[]
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  p.close()
  if outputLines.len > 0:
    res.compilationOutput = (if res.compilationOutput.len > 0: res.compilationOutput & "\n" else: "") & outputLines.join("\n")

  if p.peekExitCode() != 0:
    res.flags = {CompilationFailed}
    if fileExists(tempExeName): removeFile(tempExeName)
    return res

  if not fileExists(tempExeName):
    res.flags = {CompilationFailed}
    res.compilationOutput &= "\nError: Compiled executable not found at " & tempExeName
    return res

  p = startProcess(tempExeName, args = [],
                   options = {poUsePath, poStdErrToStdOut},
                   workingDir = exerciseDir)
  outputLines = @[] # Reset for runtime output
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  p.close()
  res.runtimeOutput = outputLines.join("\n")

  if fileExists(tempExeName): removeFile(tempExeName)

  if p.peekExitCode() != 0:
    res.flags = {RuntimeFailed}
  else:
    res.flags = {Success}
  return res

when isMainModule:
  echo "Sandbox module - for testing executeSandboxed directly."
  echo "This module is intended to be imported, not run directly for Nimlings functionality."
