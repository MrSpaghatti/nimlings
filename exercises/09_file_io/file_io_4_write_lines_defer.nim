# Description: Practice writing multiple lines to a file and using `defer` for reliable file closing.
# Hint: `defer myFile.close()` ensures `myFile.close()` is called when the current scope exits,
# whether normally or due to an exception. This is good practice for resource management.
# SandboxPreference: native
# Points: 15

import os # For removeFile

# Task:
# 1. Define a sequence of strings: `linesToWrite = @["First line.", "Second line.", "Third line."]`
# 2. Define a filename, e.g., "output2.txt".
# 3. Open the file for writing (mode `fmWrite`).
# 4. Immediately after opening, use `defer myFile.close()` to ensure it gets closed.
# 5. Loop through `linesToWrite` and write each string to the file using `myFile.writeLine()`.
# 6. After the loop (and after `close` has implicitly run due to `defer`),
#    read the entire content of "output2.txt" and print it to verify.
# 7. Clean up by deleting "output2.txt".

proc main() =
  let linesToWrite = @["First line.", "Second line.", "Third line."]
  let filename = "output2.txt"

  # TODO: Step 3, 4, 5 - Open, defer close, and write lines
  # try:
  #   var f = open(filename, fmWrite)
  #   defer: f.close() # Ensure file is closed
  #   for line in linesToWrite:
  #     f.writeLine(line)
  #   echo "Lines written to '", filename, "'." # Confirmation message
  # except IOError as e:
  #   echo "Error writing to file: ", e.msg
  echo "File writing with defer not implemented." # Placeholder


  # TODO: Step 6 - Read and print to verify
  # try:
  #   let content = readFile(filename)
  #   echo "File content after writing lines:"
  #   echo content
  # except IOError:
  #   echo "Error: Could not read '", filename, "' for verification."
  echo "Verification read not implemented." # Placeholder

  # TODO: Step 7 - Clean up the file
  # try:
  #   removeFile(filename)
  #   echo "File '", filename, "' cleaned up."
  # except OSError:
  #   echo "Warning: Could not clean up '", filename, "'."


# Do not modify the lines below; they are for testing.
when defined(testMode):
  let testFilename = "output2.txt"
  if fileExists(testFilename):
    try: removeFile(testFilename) except OSError: discard

  main()

  # Optional: Check if file is cleaned up if that's part of user's task.
  # For now, the ExpectedOutput focuses on content and the confirmation message.
else:
  main()

# ExpectedOutput: ```
# Lines written to 'output2.txt'.
# File content after writing lines:
# First line.
# Second line.
# Third line.
# File 'output2.txt' cleaned up.
# ```
