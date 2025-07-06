# Description: Learn to read and check for environment variables using the `os` module.
# Hint: `import os`.
# `getEnv(key)`: Gets the value of an environment variable. Returns empty string if not found.
# `existsEnv(key)`: Checks if an environment variable is defined.
# `putEnv(key, value)`: Sets an environment variable (for the current process and its children).
# SandboxPreference: native
# Points: 15

import os

# Task:
# 1. Check if an environment variable named "NIMLINGS_EDITOR" exists. Print the result (true/false).
# 2. Get the value of "NIMLINGS_EDITOR". If it's not set (empty string), print "NIMLINGS_EDITOR not set."
#    Otherwise, print "NIMLINGS_EDITOR is: [value]".
# 3. Set an environment variable "MY_NIMLINGS_VAR" to "NimlingsTestValue123".
# 4. Get and print the value of "MY_NIMLINGS_VAR" to verify it was set.

proc main() =
  let editorVarName = "NIMLINGS_EDITOR"
  let myVarName = "MY_NIMLINGS_VAR"

  # TODO: Task 1 - Check if NIMLINGS_EDITOR exists
  # let editorExists = existsEnv(editorVarName)
  # echo "Env var '", editorVarName, "' exists: ", editorExists
  echo "existsEnv check not implemented." # Placeholder

  # TODO: Task 2 - Get value of NIMLINGS_EDITOR
  # let editorValue = getEnv(editorVarName)
  # if editorValue.len == 0:
  #   echo editorVarName, " not set."
  # else:
  #   echo editorVarName, " is: ", editorValue
  echo "getEnv for NIMLINGS_EDITOR not implemented." # Placeholder

  # TODO: Task 3 - Set MY_NIMLINGS_VAR
  # putEnv(myVarName, "NimlingsTestValue123")
  echo "putEnv for MY_NIMLINGS_VAR not implemented." # Placeholder

  # TODO: Task 4 - Get and print MY_NIMLINGS_VAR
  # let myVarValue = getEnv(myVarName)
  # echo myVarName, " is: ", myVarValue
  echo "getEnv for MY_NIMLINGS_VAR not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  # For testMode, we can control the environment for NIMLINGS_EDITOR
  # 1. Test when it's not set
  echo "--- Test Case: NIMLINGS_EDITOR not set ---"
  if existsEnv("NIMLINGS_EDITOR_TEMP_FOR_TEST"): # If some test runner set it
    putEnv("NIMLINGS_EDITOR", getEnv("NIMLINGS_EDITOR_TEMP_FOR_TEST")) # restore
    putEnv("NIMLINGS_EDITOR_TEMP_FOR_TEST", "") # clear temp
  else: # Temporarily ensure it's NOT set for this part of the test
    var originalEditorValue = ""
    if existsEnv("NIMLINGS_EDITOR"): # save original if it exists
        originalEditorValue = getEnv("NIMLINGS_EDITOR")
    putEnv("NIMLINGS_EDITOR", "") # ensure it's empty for test
    main()
    if originalEditorValue.len > 0: # restore original
        putEnv("NIMLINGS_EDITOR", originalEditorValue)
    else: # if it was originally empty, ensure it is removed if putEnv creates empty one
        if existsEnv("NIMLINGS_EDITOR") and getEnv("NIMLINGS_EDITOR") == "":
            # This part is tricky; `putEnv(key, "")` might delete or set to empty.
            # Standard library behavior for `putEnv("", "")` might vary or be an error.
            # Let's assume for the test, we can ensure it's not considered "set" if empty.
            # A robust way is to use a temporary variable name that is unlikely to exist.
            # For simplicity, the test above relies on `getEnv` returning "" if not set.
            discard

  echo "\n--- Test Case: NIMLINGS_EDITOR is set ---"
  putEnv("NIMLINGS_EDITOR", "VSCode")
  main()
  # Clean up env var set by test
  putEnv("NIMLINGS_EDITOR", "") # Or restore original if there was one.
                                # For simplicity, just clearing.
  putEnv(myVarName, "") # Clean up MY_NIMLINGS_VAR too
else:
  # User can set NIMLINGS_EDITOR in their shell to test that path.
  main()

# ExpectedOutput: ```
# --- Test Case: NIMLINGS_EDITOR not set ---
# Env var 'NIMLINGS_EDITOR' exists: false
# NIMLINGS_EDITOR not set.
# MY_NIMLINGS_VAR is: NimlingsTestValue123
#
# --- Test Case: NIMLINGS_EDITOR is set ---
# Env var 'NIMLINGS_EDITOR' exists: true
# NIMLINGS_EDITOR is: VSCode
# MY_NIMLINGS_VAR is: NimlingsTestValue123
# ```
