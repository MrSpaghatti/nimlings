# Description: Learn to create and delete files and directories using the `os` module.
# Hint: `import os`.
# `createDir(path)` creates a directory.
# `removeDir(path)` removes an empty directory.
# `writeFile(path, content)` creates/overwrites a file with content.
# `removeFile(path)` deletes a file.
# Use `try/except OSError` to handle potential errors for these operations.
# SandboxPreference: native
# Points: 20

import os

# Task:
# 1. Define a base temporary directory name, e.g., "my_temp_stuff".
# 2. Create this directory. Print a success message or error.
# 3. Inside this directory, create a file named "notes.txt" with content "Temporary notes.". Print success/error.
# 4. Check if "notes.txt" exists in that directory. Print the result.
# 5. Delete the file "notes.txt". Print success/error.
# 6. Check if "notes.txt" still exists. Print the result.
# 7. Delete the directory "my_temp_stuff". Print success/error.
# 8. Check if the directory "my_temp_stuff" still exists. Print the result.
# Ensure all operations are within try/except blocks for OSErrors.

proc main() =
  let baseDir = "my_temp_stuff"
  let filePath = baseDir / "notes.txt" # Using ospaths / for joining

  # --- Initial cleanup for robust testing/reruns ---
  if dirExists(baseDir):
    if fileExists(filePath):
      try: removeFile(filePath) except OSError: discard
    try: removeDir(baseDir) except OSError: discard
  # --- End initial cleanup ---

  # TODO: Step 2 - Create baseDir
  # try:
  #   createDir(baseDir)
  #   echo "Directory '", baseDir, "' created successfully."
  # except OSError as e:
  #   echo "Error creating directory '", baseDir, "': ", e.msg
  echo "Directory creation not implemented." # Placeholder

  # TODO: Step 3 - Create notes.txt in baseDir
  # try:
  #   writeFile(filePath, "Temporary notes.")
  #   echo "File '", filePath, "' created successfully."
  # except IOError as e: # writeFile raises IOError
  #   echo "Error writing file '", filePath, "': ", e.msg
  echo "File writing not implemented." # Placeholder

  # TODO: Step 4 - Check if notes.txt exists
  # echo "File '", filePath, "' exists after creation: ", fileExists(filePath)
  echo "File existence check (1) not implemented." # Placeholder

  # TODO: Step 5 - Delete notes.txt
  # try:
  #   if fileExists(filePath): removeFile(filePath) # Check first to avoid error if already gone
  #   echo "File '", filePath, "' deleted successfully."
  # except OSError as e:
  #   echo "Error deleting file '", filePath, "': ", e.msg
  echo "File deletion not implemented." # Placeholder

  # TODO: Step 6 - Check if notes.txt still exists
  # echo "File '", filePath, "' exists after deletion: ", fileExists(filePath)
  echo "File existence check (2) not implemented." # Placeholder

  # TODO: Step 7 - Delete baseDir
  # try:
  #   if dirExists(baseDir): removeDir(baseDir) # Check first
  #   echo "Directory '", baseDir, "' deleted successfully."
  # except OSError as e:
  #   echo "Error deleting directory '", baseDir, "': ", e.msg
  echo "Directory deletion not implemented." # Placeholder

  # TODO: Step 8 - Check if baseDir still exists
  # echo "Directory '", baseDir, "' exists after deletion: ", dirExists(baseDir)
  echo "Directory existence check (2) not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
  # Final cleanup in case user logic missed something, good for robust tests
  let baseDir = "my_temp_stuff"
  let filePath = baseDir / "notes.txt"
  if fileExists(filePath): try: removeFile(filePath) except OSError: discard
  if dirExists(baseDir): try: removeDir(baseDir) except OSError: discard
else:
  main()

# ExpectedOutput: ```
# Directory 'my_temp_stuff' created successfully.
# File 'my_temp_stuff/notes.txt' created successfully.
# File 'my_temp_stuff/notes.txt' exists after creation: true
# File 'my_temp_stuff/notes.txt' deleted successfully.
# File 'my_temp_stuff/notes.txt' exists after deletion: false
# Directory 'my_temp_stuff' deleted successfully.
# Directory 'my_temp_stuff' exists after deletion: false
# ```
