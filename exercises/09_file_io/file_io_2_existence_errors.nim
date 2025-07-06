# Description: Check for file existence and handle potential errors during file reading.
# Hint: `import os`. Use `os.fileExists(filename)` to check if a file exists.
# Use `try/except IOError` to catch errors that might occur when trying to read a file
# (e.g., file exists but you don't have permission, or other OS-level read issues).
#
# For this exercise, we'll work with two conceptual files for testing:
# - `test_exists.txt`: Assume this file exists and contains "Content of existing file."
# - `non_existent.txt`: Assume this file does not exist.
#
# SandboxPreference: native
# Points: 15

import os # For fileExists

# Task:
# Create a procedure `readFileSafely(filename: string)` that:
# 1. Checks if the file exists.
# 2. If it exists, it tries to read the file using `readFile()`.
#    - If reading is successful, it prints "Content of [filename]:\n[content]".
#    - If an `IOError` occurs during reading (e.g., permissions), it prints "Error: Could not read [filename] due to IO issue."
# 3. If the file does not exist, it prints "Error: File [filename] not found."

# TODO: Define readFileSafely procedure here
# proc readFileSafely(filename: string) =
#   ...

proc main() =
  # These filenames are for the exercise logic.
  # The testMode block below will simulate their state.
  let existingFile = "test_exists.txt"
  let missingFile = "non_existent.txt"

  # TODO: Call readFileSafely for existingFile
  # readFileSafely(existingFile)
  echo "Call for existing file not implemented." # Placeholder

  # TODO: Call readFileSafely for missingFile
  # readFileSafely(missingFile)
  echo "Call for missing file not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  # Simulate file system state for testing
  let existingFileName = "test_exists.txt"
  let existingFileContent = "Content of existing file."
  let missingFileName = "non_existent.txt"

  # Create the "existing" file
  try:
    writeFile(existingFileName, existingFileContent)
  except IOError:
    echo "Test setup error: Could not write ", existingFileName
    quit(1)

  # Ensure the "missing" file does not exist
  if fileExists(missingFileName):
    try:
      removeFile(missingFileName)
    except OSError:
      echo "Test setup error: Could not remove ", missingFileName
      # Continue if removal fails, test might still reflect correct logic for non-existence.

  main() # Calls the user's readFileSafely with these filenames

  # Clean up
  if fileExists(existingFileName):
    try:
      removeFile(existingFileName)
    except OSError:
      discard # Ignore cleanup error
else:
  # For manual runs, the user needs to create "test_exists.txt" themselves
  # and ensure "non_existent.txt" does not exist to see both paths.
  echo "Manual run: Create 'test_exists.txt' with some content to test the existing file path."
  echo "Ensure 'non_existent.txt' does not exist to test the missing file path."
  main()

# ExpectedOutput: ```
# Content of test_exists.txt:
# Content of existing file.
# Error: File non_existent.txt not found.
# ```
