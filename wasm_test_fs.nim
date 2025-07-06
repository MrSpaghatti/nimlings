import os

echo "--- Filesystem Access Test ---"

echo "Attempting to list current directory ('.'). Expect failure or empty/restricted output."
try:
  var count = 0
  for kind, path in walkDir("."):
    echo "Found: ", path
    count += 1
  if count == 0:
    echo "walkDir('.') produced no items (or was restricted)."
except OSError as e:
  echo "[PASS] OSError listing dir '.': ", e.msg
except CatchableError as e:
  echo "[PASS] Error listing dir '.': ", e.msg

echo "\nAttempting to create file 'wasm_fs_test_output.txt'. Expect failure."
let testFileName = "wasm_fs_test_output.txt"
try:
  writeFile(testFileName, "Hello from WASM FS test.")
  # If writeFile succeeds, it's a failure of sandboxing for write
  echo "[FAIL] writeFile operation appeared to succeed."
  if fileExists(testFileName):
    echo "[FAIL] File '", testFileName, "' was actually created."
    try:
      removeFile(testFileName) # Clean up if created
    except OSError:
      discard
  else:
    echo "[INFO] writeFile succeeded but file does not exist afterwards?" # Should not happen
except OSError as e:
  echo "[PASS] OSError writing file: ", e.msg
except CatchableError as e:
  echo "[PASS] Error writing file: ", e.msg

echo "\nAttempting to read a known non-existent file 'hopefully_does_not_exist.txt'. Expect failure."
try:
  let content = readFile("hopefully_does_not_exist.txt")
  echo "[FAIL] readFile operation on non-existent file seemed to succeed. Content: ", content
except OSError as e:
  echo "[PASS] OSError reading non-existent file: ", e.msg
except CatchableError as e:
  echo "[PASS] Error reading non-existent file: ", e.msg


echo "--- Filesystem Access Test Finished ---"
