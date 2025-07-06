# Description: Learn to check for file and directory existence using the `os` module.
# Hint: `import os`. Use `fileExists(path)` and `dirExists(path)`.
# These functions return `true` if the path exists and is a file/directory respectively, `false` otherwise.
# SandboxPreference: native
# Points: 10

import os

# Task:
# For testing, we will simulate file/directory states.
# 1. Check if a path named "testfile.txt" exists as a file.
# 2. Check if a path named "testdir" exists as a directory.
# 3. Check if a path named "nonexistent.dat" exists as a file.

proc main() =
  let fileToCheck = "testfile.txt"
  let dirToCheck = "testdir"
  let nonExistentFile = "nonexistent.dat"

  # In a real scenario, these files/dirs would exist or not on the filesystem.
  # For this exercise, the `when defined(testMode)` block will create them temporarily.

  # TODO: Task 1 - Check for fileToCheck
  # echo "File '", fileToCheck, "' exists: ", fileExists(fileToCheck)
  echo "File existence check for '", fileToCheck, "' not implemented." # Placeholder

  # TODO: Task 2 - Check for dirToCheck
  # echo "Directory '", dirToCheck, "' exists: ", dirExists(dirToCheck)
  echo "Directory existence check for '", dirToCheck, "' not implemented." # Placeholder

  # TODO: Task 3 - Check for nonExistentFile
  # echo "File '", nonExistentFile, "' exists: ", fileExists(nonExistentFile)
  echo "File existence check for '", nonExistentFile, "' not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  # Setup: Create a dummy file and directory for testing
  let testFile = "testfile.txt"
  let testDir = "testdir"
  try:
    writeFile(testFile, "dummy content")
  except IOError:
    echo "Test setup error: Could not write ", testFile
    quit(1)
  try:
    createDir(testDir)
  except OSError: # createDir raises OSError on failure
    echo "Test setup error: Could not create dir ", testDir
    # If dir already exists, it might also raise error depending on Nim version/OS.
    # For robustness, check if it exists if createDir failed.
    if not dirExists(testDir): quit(1)


  main() # Run the student's code

  # Teardown: Clean up dummy file and directory
  try:
    removeFile(testFile)
  except OSError: discard # Ignore cleanup error
  try:
    removeDir(testDir)
  except OSError: discard # Ignore cleanup error
else:
  echo "Manual run: Create 'testfile.txt' and a directory 'testdir' to see true results."
  echo "Ensure 'nonexistent.dat' does not exist."
  main()

# ExpectedOutput: ```
# File 'testfile.txt' exists: true
# Directory 'testdir' exists: true
# File 'nonexistent.dat' exists: false
# ```
