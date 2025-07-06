# Description: Learn to write content to files and append to existing files.
# Hint: `writeFile(filename, content)` overwrites a file or creates it with new content.
# To append, `open(filename, fmAppend)` then `myFile.writeLine(text)` or `myFile.write(text)`, and finally `myFile.close()`.
# SandboxPreference: native
# Points: 15

# Task:
# 1. Define a filename, e.g., "output1.txt".
# 2. Write the string "Initial line." to this file using `writeFile`.
# 3. Open the same file in append mode (`fmAppend`).
# 4. Write a new line "Appended line." to it.
# 5. Close the file.
# 6. Read the entire content of "output1.txt" and print it to verify.
# 7. Clean up by deleting "output1.txt" (use `os.removeFile` inside a try block for safety).

import os # For removeFile

proc main() =
  let filename = "output1.txt"

  # TODO: Step 2 - Write initial content
  # writeFile(filename, "Initial line.")
  echo "Initial write not implemented." # Placeholder

  # TODO: Step 3, 4, 5 - Open in append mode, write, and close
  # var f = open(filename, fmAppend)
  # f.writeLine("Appended line.")
  # f.close()
  echo "Append operation not implemented." # Placeholder

  # TODO: Step 6 - Read and print to verify
  # try:
  #   let content = readFile(filename)
  #   echo "File content after operations:"
  #   echo content
  # except IOError:
  #   echo "Error: Could not read '", filename, "' for verification."
  echo "Verification read not implemented." # Placeholder

  # TODO: Step 7 - Clean up the file
  # try:
  #   removeFile(filename)
  #   echo "File '", filename, "' cleaned up."
  # except OSError: # removeFile raises OSError on failure
  #   echo "Warning: Could not clean up '", filename, "'."


# Do not modify the lines below; they are for testing.
when defined(testMode):
  # Ensure file does not exist before test
  let testFilename = "output1.txt"
  if fileExists(testFilename):
    try: removeFile(testFilename) except OSError: discard

  main()

  # Test might optionally check if file is indeed removed,
  # but ExpectedOutput focuses on the content creation part.
  # If main() is expected to remove it, then the cleanup message should be in ExpectedOutput.
else:
  main()

# ExpectedOutput: ```
# File content after operations:
# Initial line.
# Appended line.
# File 'output1.txt' cleaned up.
# ```
