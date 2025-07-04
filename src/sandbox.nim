# Nimlings Sandbox Module
#
# Responsible for executing user-submitted exercise code in a more controlled environment.
#
# CURRENT STATUS: THIS IS A PLACEHOLDER AND NOT A SECURE SANDBOX.
# The current implementation directly uses osproc, which offers no real security isolation.
#
# --- Research & Future Directions for True Sandboxing ---
#
# 1. WebAssembly (WASM):
#    - Pros: Designed for sandboxing, good cross-platform potential, Nim supports WASM compilation.
#            Memory safe, capability-based security by default.
#    - Cons: Requires a WASM runtime. Interfacing with host system for I/O (like `echo`)
#            needs careful design (WASI or custom import/export). Might complicate build process for exercises.
#    - Viability: High for strong sandboxing.
#
# 2. OS-Level Sandboxing Tools (e.g., bubblewrap on Linux, sandbox-exec on macOS):
#    - Pros: Leverages robust OS security features (namespaces, seccomp, profiles).
#    - Cons: Adds external dependencies. OS-specific solutions require different implementations.
#            Profiles can be complex to write and maintain.
#    - Viability: Medium; good for stronger isolation if dependencies are acceptable.
#
# 3. Language-Level Restrictions & Static Analysis:
#    - Pros: No external dependencies.
#    - Cons: Very difficult to make robust. Easy to bypass (e.g., through FFI, complex metaprogramming).
#            Not a true sandbox. Could be a supplementary layer.
#    - Viability: Low as a primary sandboxing mechanism.
#
# 4. Containerization (Docker, Podman):
#    - Pros: Very strong isolation.
#    - Cons: Heavy dependency for a CLI tool. Significant overhead.
#    - Viability: Low for a local CLI tool, high for a potential web-based version.
#
# 5. PTrace (Syscall Tracing):
#    - Pros: Fine-grained control.
#    - Cons: Extremely complex to implement correctly and securely. Performance overhead. OS-specific.
#    - Viability: Very Low due to complexity.
#
# Recommended Path for Future Development:
# - Short-term: Focus on clear warnings about code execution.
# - Mid-term: Investigate WASM. Compile exercises to WASM and run with a suitable runtime.
# - Long-term: If stronger, native isolation is needed and dependencies are OK, explore OS-specific tools.
#

import osproc
import os
import strutils

# Re-using types from nimlings.nim for consistency.
# Ideally, these might be in a shared types module if complexity grows.
type RunResultFlag* = enum
  CompilationFailed,
  RuntimeFailed,
  ValidationFailed,
  Success

type SandboxedExecutionResult* = object
  flags*: set[RunResultFlag]
  compilationOutput*: string
  runtimeOutput*: string
  # validationOutput is handled by the caller (runExercise)

proc executeSandboxed*(
    filePath: string,
    exerciseDir: string, # Directory where the exercise exists, for context
    allowedReadPaths: seq[string] = @[], # Future: for controlling FS read access
    allowedWritePaths: seq[string] = @[] # Future: for controlling FS write access
  ): SandboxedExecutionResult =
  ## Executes the Nim code at filePath in a sandboxed environment.
  ##
  ## WARNING: CURRENTLY NOT A SECURE SANDBOX. USES OSPROC DIRECTLY.
  ##
  ## `filePath`: Absolute path to the .nim exercise file.
  ## `exerciseDir`: Working directory for compilation and execution.
  ## `allowedReadPaths`, `allowedWritePaths`: Placeholders for future FS restrictions.

  var res: SandboxedExecutionResult
  let nimexe = "nim" # Assuming nim compiler is in PATH

  # This implementation mirrors the non-sandboxed path from nimlings.nim's compileAndRun
  # It's placed here to establish the interface for future sandboxing.

  # 1. Compilation Check (nim check)
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

  # 2. Actual Compilation
  let tempExeName = filePath.changeFileExt(".exe_temp_sandbox") # Avoid collision
  p = startProcess(nimexe, args = ["compile", "--hints:off", "--verbosity:0", "--out:" & tempExeName, filePath],
                   options = {poStdErrToStdOut, poUsePath}, workingDir = exerciseDir)
  outputLines = @[]
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  p.close()
  # Append to check output, as 'check' might miss some things 'compile' catches or vice-versa.
  if outputLines.len > 0:
    res.compilationOutput = (if res.compilationOutput.len > 0: res.compilationOutput & "\n" else: "") & outputLines.join("\n")


  if p.peekExitCode() != 0:
    res.flags = {CompilationFailed}
    if fileExists(tempExeName): removeFile(tempExeName)
    return res

  # 3. Run Step (if compilation succeeded)
  if not fileExists(tempExeName):
    res.flags = {CompilationFailed}
    res.compilationOutput &= "\nError: Compiled executable not found at " & tempExeName
    return res

  # Here, actual sandboxing would apply to the execution of `tempExeName`
  # For now, it's direct osproc.
  p = startProcess(tempExeName, args = [],
                   options = {poUsePath, poStdErrToStdOut}, # poStdErrToStdOut mixes runtime errors with stdout
                   workingDir = exerciseDir)
  var runStdoutLines: seq[string] = @[]
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: runStdoutLines.add(line)
  p.close()
  res.runtimeOutput = runStdoutLines.join("\n")

  if fileExists(tempExeName): removeFile(tempExeName)

  if p.peekExitCode() != 0:
    res.flags = {RuntimeFailed}
  else:
    res.flags = {Success} # Tentatively success, pending validation by caller

  return res

when isMainModule:
  echo "Sandbox module - for testing executeSandboxed directly."
  # To test this, you'd need a dummy Nim file.
  # Example: create a `dummy_exercise.nim` with `echo "Hello from sandbox test"`
  # Then call:
  # let result = executeSandboxed("path/to/dummy_exercise.nim", "path/to/dir_of_dummy")
  # echo result
  echo "This module is intended to be imported, not run directly for Nimlings functionality."
