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
import wasmer # For embedded WASM runtime
from wasmer import wasi # For WASI environment setup

# Conceptual Dependency: `wasmer` nimble package.

type RunResultFlag* = enum
  CompilationFailed,
  RuntimeFailed,
  ValidationFailed, # Note: This flag is set by the caller (runExercise), not directly here.
  Success

type SandboxedExecutionResult* = object
  flags*: set[RunResultFlag]
  compilationOutput*: string
  runtimeOutput*: string

proc executeWASM_ViaNimRun_PoC(filePath: string, exerciseDir: string): SandboxedExecutionResult = # Renamed from executeWASM_PoC
  ## Proof-of-Concept for WASM execution.
  ## This version attempts to use `nim compile --os:wasi --cpu:wasm32 -r <file>`
  ## which relies on a system-configured WASI runner. (LEGACY PoC)
  var res: SandboxedExecutionResult
  let nimexe = "nim"

  echo "Attempting WASM compile & run (via nim c -r) for: ", filePath

  var p = startProcess(nimexe,
                       args = ["compile", "--os:wasi", "--cpu:wasm32", "-r",
                               "--verbosity:0", "--hints:off",
                               "--warning[ObservableStores]:off",
                               filePath],
                       options = {poStdErrToStdOut, poUsePath},
                       workingDir = exerciseDir)

  var combinedOutputLines: seq[string]
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: combinedOutputLines.add(line)
  p.close()

  let exitCode = p.peekExitCode()
  let fullOutput = combinedOutputLines.join("\n")

  if exitCode == 0:
    res.flags = {Success}
    res.runtimeOutput = fullOutput
    var actualRuntimeOutputLines: seq[string]
    for line in combinedOutputLines:
      if not (line.contains(filePath) and (line.contains(".nim(") or line.contains(" Hint:") or line.contains(" Warning:"))):
        actualRuntimeOutputLines.add(line)

    if actualRuntimeOutputLines.len > 0 and actualRuntimeOutputLines.join("").strip().len > 0:
       var hasNonCompilerLikeLine = false
       for line in actualRuntimeOutputLines:
         if not (line.startsWith("Hint") or line.startsWith("Warning") or line.startsWith("Info") or line.startsWith("Success") or line.startsWith("CC:")):
           hasNonCompilerLikeLine = true
           break
       if hasNonCompilerLikeLine:
         res.runtimeOutput = actualRuntimeOutputLines.join("\n")
       else:
         res.runtimeOutput = fullOutput
    else:
       res.runtimeOutput = fullOutput
    res.compilationOutput = "WASM compilation and run via `nim c -r` reported success."
  else:
    res.flags = {CompilationFailed}
    res.compilationOutput = "WASM compile & run via `nim c -r` failed. Output:\n" & fullOutput
    res.runtimeOutput = ""
  return res

const DEFAULT_WASM_FUEL = 200_000_000 # Default fuel units, adjust as needed (e.g. 200 million)

proc executeWASM_EmbedRuntime_PoC(filePath: string, exerciseDir: string): SandboxedExecutionResult =
  ## Proof-of-Concept for WASM execution using an embedded Wasmer runtime.
  ## This function attempts to:
  ## 1. Compile the input Nim source file (`.nim`) to a WebAssembly file (`.wasm`).
  ## 2. Load and execute this `.wasm` file using the Wasmer runtime with fuel metering.
  ## 3. Capture stdout/stderr from the WASM execution using OS pipes.
  ##
  ## Limitations of this PoC:
  ## - WASI Support: Basic stdout/stderr. More complex WASI features not extensively tested.
  ## - Security: WASM memory isolation + basic WASI (stdio) + Fuel. Fine-grained capabilities TBD.
  ## - Fuel Amount: `DEFAULT_WASM_FUEL` is arbitrary; may need tuning.
  ##
  var res: SandboxedExecutionResult
  let nimexe = "nim"
  let wasmOutFile = filePath.changeFileExt(".wasm")

  # --- Resource Limiting Considerations (Time/Memory) ---
  # Memory Limiting: Primarily via module's declared max and indirectly via fuel.
  # Execution Time Limiting: Implemented via Fuel/Metering.
  # Current PoC Implementation: Implements fuel-based metering.
  # Epoch interruption is another option but more complex.

  echo "Attempting WASM compilation (to .wasm file) for: ", filePath
  var pCompile = startProcess(nimexe,
                              args = ["compile", "--os:wasi", "--cpu:wasm32", "--out:" & wasmOutFile, "--compileOnly", filePath],
                              options = {poStdErrToStdOut, poUsePath},
                              workingDir = exerciseDir)
  var compileOutputLines: seq[string]
  while pCompile.running():
    if pCompile.peekExitCode != -1: break
    var line = pCompile.outputStream().readLine()
    if line.len > 0: compileOutputLines.add(line)
  pCompile.close()
  res.compilationOutput = compileOutputLines.join("\n")

  if pCompile.peekExitCode() != 0:
    res.flags = {CompilationFailed}
    if fileExists(wasmOutFile): removeFile(wasmOutFile)
    return res

  if not fileExists(wasmOutFile):
    res.flags = {CompilationFailed}
    res.compilationOutput &= "\nError: WASM compilation reported success, but output file " & wasmOutFile & " not found."
    return res

  echo "WASM compilation successful: ", wasmOutFile
  res.compilationOutput = "WASM Compilation to " & wasmOutFile & " successful.\n" & res.compilationOutput

  var pipeStdoutRead, pipeStdoutWrite: FileHandle
  var pipeStderrRead, pipeStderrWrite: FileHandle
  var wasmerInstance: Instance = nil # To ensure it's declared for finally if needed

  try:
    echo "Initializing Wasmer engine with fuel consumption..."
    var compilerConfig = newCompilerConfig()
    compilerConfig.setFuelConsumption(true) # Enable fuel consumption
    let engine = newEngine(compilerConfig)
    let store = newStore(engine)

    echo "Reading WASM bytes from ", wasmOutFile, "..."
    let wasmBytes = readFile(wasmOutFile).toOpenArrayByte(0, readFile(wasmOutFile).len - 1)

    echo "Compiling WASM bytes with Wasmer..."
    let module = newModule(store, wasmBytes)

    echo "Setting up WASI environment..."
    var wasiEnv = newWasiStateBuilder("nimlings-exercise")
    # No addEnv, addArg, addPreopenDir called -> empty env, no args, no FS access by default.

    if not os.pipe(pipeStdoutRead, pipeStdoutWrite):
      res.flags = {RuntimeFailed}; res.runtimeOutput = "Failed to create stdout pipe for WASM."
      if fileExists(wasmOutFile): removeFile(wasmOutFile); return res
    defer: pipeStdoutRead.close(); pipeStdoutWrite.close()

    if not os.pipe(pipeStderrRead, pipeStderrWrite):
      res.flags = {RuntimeFailed}; res.runtimeOutput = "Failed to create stderr pipe for WASM."
      if fileExists(wasmOutFile): removeFile(wasmOutFile); return res
    defer: pipeStderrRead.close(); pipeStderrWrite.close()

    wasiEnv.setStdout(pipeStdoutWrite)
    wasiEnv.setStderr(pipeStderrWrite)

    let importObject = wasiEnv.finalize(store, module)
    if importObject == nil:
      res.flags = {RuntimeFailed}; res.runtimeOutput = "Failed to finalize WASI environment."
      if fileExists(wasmOutFile): removeFile(wasmOutFile); return res

    echo "Instantiating WASM module with Wasmer..."
    wasmerInstance = newInstance(store, module, importObject) # Assign to outer scope var

    echo "Adding fuel to store: ", DEFAULT_WASM_FUEL
    store.addFuel(DEFAULT_WASM_FUEL)

    echo "Getting '_start' function from WASM instance..."
    let startFunc = wasmerInstance.exports.getProc("_start")
    if startFunc == nil:
      res.flags = {RuntimeFailed}; res.runtimeOutput = "WASM Execution Error: _start function not found."
      if fileExists(wasmOutFile): removeFile(wasmOutFile); return res

    echo "Executing '_start' function (WASM)..."
    startFunc()
    echo "WASM execution finished."

    let fuelConsumed = DEFAULT_WASM_FUEL - store.getFuelLeft(wasmerInstance) # Get remaining fuel from instance/store
    echo "Approximate fuel consumed: ", fuelConsumed

    pipeStdoutWrite.close()
    pipeStderrWrite.close()

    let capturedStdout = pipeStdoutRead.readAll()
    let capturedStderr = pipeStderrRead.readAll()

    var finalRuntimeOutput = ""
    if capturedStdout.len > 0: finalRuntimeOutput &= capturedStdout
    if capturedStderr.len > 0:
      if finalRuntimeOutput.len > 0: finalRuntimeOutput &= "\n---Stderr---\n"
      finalRuntimeOutput &= capturedStderr

    res.runtimeOutput = if finalRuntimeOutput.strip().len > 0: finalRuntimeOutput else: "(WASM module produced no stdout/stderr)"
    res.flags = {Success}

  except Trap as e:
    res.flags = {RuntimeFailed}
    var trapMsg = "[WASM Trap] " & e.msg
    if "fuel" in e.msg.toLower() or (defined(wasmerFuelExhaustedCode) and e.code == wasmerFuelExhaustedCode): # Hypothetical code check
        trapMsg &= "\n(This likely indicates fuel exhaustion, meaning the program took too long or did too much computation.)"
    else:
        trapMsg &= "\n(Note: This indicates an error within the WebAssembly module execution, like division by zero, out-of-bounds memory access, or an explicit trap instruction.)"
    res.runtimeOutput = trapMsg
  except CatchableError as e:
    res.flags = {RuntimeFailed}
    res.runtimeOutput = "[WASM Host Error] " & e.name & ": " & e.msg
  finally:
    if pipeStdoutWrite.isAssociated: pipeStdoutWrite.close()
    if pipeStderrWrite.isAssociated: pipeStderrWrite.close()

  if fileExists(wasmOutFile): removeFile(wasmOutFile)
  return res


proc executeSandboxed*(
    filePath: string,
    exerciseDir: string,
    allowedReadPaths: seq[string] = @[],
    allowedWritePaths: seq[string] = @[],
    preference: string = "native"
  ): SandboxedExecutionResult =
  if preference == "wasm":
    echo "Sandbox: WASM preference selected (Embedded Wasmer Runtime with Fuel PoC)."
    return executeWASM_EmbedRuntime_PoC(filePath, exerciseDir)

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
    res.flags = {CompilationFailed}; return res

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

  p = startProcess(tempExeName, args = [], options = {poUsePath, poStdErrToStdOut}, workingDir = exerciseDir)
  outputLines = @[]
  while p.running():
    if p.peekExitCode != -1: break
    var line = p.outputStream().readLine()
    if line.len > 0: outputLines.add(line)
  p.close()
  res.runtimeOutput = outputLines.join("\n")

  if fileExists(tempExeName): removeFile(tempExeName)

  if p.peekExitCode() != 0: res.flags = {RuntimeFailed}
  else: res.flags = {Success}
  return res

when isMainModule:
  echo "Sandbox module - Test playground"

  proc runWasmTest(testFile: string, expectedToTrap: bool = false) =
    echo "\n>>> Running WASM Test: ", testFile
    let exercisesRoot = getExercisesRootPath() # Assuming this proc is available or defined
    let filePath = if fileExists(testFile): testFile else: exercisesRoot / "common_test_files" / testFile

    if not fileExists(filePath):
      echo "Test file '", filePath, "' not found. Skipping."
      return

    # For tests, ensure the exerciseDir is where the .nim file is, if it's not CWD.
    let exerciseDir = parentDir(filePath)
    let result = executeWASM_EmbedRuntime_PoC(filePath, exerciseDir)
    echo "--- Output for ", testFile, " ---"
    echo "Compilation Output:\n", result.compilationOutput
    echo "Runtime Output:\n", result.runtimeOutput
    echo "--- Flags for ", testFile, ": ", result.flags, " ---"
    if Success in result.flags: echo "Execution reported success (no trap)."
    if CompilationFailed in result.flags: echo "Execution reported COMPILE FAILED."
    if RuntimeFailed in result.flags: echo "Execution reported RUNTIME FAILED (trap or host error)."
    if expectedToTrap and RuntimeFailed in result.flags and "[WASM Trap]" in result.runtimeOutput and "fuel" in result.runtimeOutput.toLower():
        echo "[PASS] Expected trap due to fuel exhaustion occurred."
    elif expectedToTrap and not (RuntimeFailed in result.flags and "[WASM Trap]" in result.runtimeOutput and "fuel" in result.runtimeOutput.toLower()):
        echo "[FAIL] Expected trap due to fuel exhaustion DID NOT occur or message was different."
    elif not expectedToTrap and RuntimeFailed in result.flags and "[WASM Trap]" in result.runtimeOutput and "fuel" in result.runtimeOutput.toLower():
        echo "[FAIL] UNEXPECTED trap due to fuel exhaustion occurred."


  echo "\n--- Testing WASM Capability Restrictions (FS/Env) ---"
  runWasmTest("wasm_test_fs.nim")       # Should run, operations inside should fail gracefully
  runWasmTest("wasm_test_env.nim")      # Should run, env vars should be empty

  echo "\n--- Testing WASM Fuel Metering ---"
  runWasmTest("wasm_infinite_loop.nim", expectedToTrap = true) # Expect this to trap due to fuel

  # Cleanup for non-exercise test files created by agent
  let commonTestFilesDir = getExercisesRootPath() / "common_test_files"
  if fileExists(commonTestFilesDir / "wasm_infinite_loop.nim"): try: removeFile(commonTestFilesDir / "wasm_infinite_loop.nim") except: discard
  # wasm_test_fs.nim and wasm_test_env.nim are expected to be at repo root by runWasmTest if not found in common_test_files
  if fileExists("wasm_test_fs.nim"): try: removeFile("wasm_test_fs.nim") except: discard
  if fileExists("wasm_test_env.nim"): try: removeFile("wasm_test_env.nim") except: discard

  echo "\n--- Sandbox module testing complete ---"
