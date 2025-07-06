import os

echo "--- Environment Variable Access Test ---"

proc checkEnv(varName: string) =
  let val = getEnv(varName)
  if val.len > 0:
    echo "[FAIL] Environment variable '", varName, "' was found. Value: ", val
  else:
    echo "[PASS] Environment variable '", varName, "' not found or is empty."

checkEnv("PATH")
checkEnv("HOME")
checkEnv("USER")
checkEnv("LANG")
checkEnv("NIMLINGS_TEST_ENV_VAR") # A custom one unlikely to exist

# Test setting an env var (shouldn't affect host, and might not be allowed by WASI anyway)
echo "\nAttempting to set an environment variable 'MY_WASM_VAR' (should not persist or affect host)."
try:
  putEnv("MY_WASM_VAR", "wasm_value")
  # Now try to get it back within the same WASM instance
  let myVar = getEnv("MY_WASM_VAR")
  if myVar == "wasm_value":
    echo "[INFO] putEnv/getEnv for 'MY_WASM_VAR' worked within WASM instance. This is fine."
  else:
    echo "[INFO] putEnv for 'MY_WASM_VAR' did not allow getEnv in same instance, or value mismatch."
except CatchableError as e:
  echo "[INFO] Error trying to putEnv: ", e.msg # putEnv itself might be restricted

# Double check it's not leaking from host if it was set by host for some reason
let stillMyVar = getEnv("MY_WASM_VAR")
if stillMyVar == "wasm_value" and getEnv("NIMLINGS_TEST_ENV_VAR").len == 0 : # ensure it wasn't set by host
    discard # already logged by [INFO]
elif stillMyVar.len > 0 :
    echo "[WARN] 'MY_WASM_VAR' has a value '", stillMyVar, "' that might be from host or unexpected."


echo "\n--- Environment Variable Access Test Finished ---"
