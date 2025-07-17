# Description: Learn to use FileStream for file I/O and StringStream for in-memory string building, understanding their common use cases.
# Hint: For `FileStream`, use `open(filename, fmWrite/fmRead)`, `writeLine()`, `readLine()`, and remember to `close()` streams (ideally with `defer` or `try/finally`). Use `std/tempfiles.newTempFile()` for temporary filenames, and `os.removeFile()` for cleanup. For `StringStream`, use `newStringStream()`, `write()`, and `ss.data` to get the content.
# Points: 30
# SandboxPreference: native
# ExpectedOutput: ```
# --- FileStream Operations ---
# Writing data to a temporary file...
# Content written to file:
# Name: Test User
# ID: 123
# Value: 3.14
# Reading data from the temporary file...
# Content read from file:
# Name: Test User
# ID: 123
# Value: 3.14
# Temporary file operations complete.
# --- StringStream Operations ---
# Building string with StringStream...
# StringStream result: Report for item_abc: status OK, count 25.
# ```

import std/streams
import std/tempfiles
import std/os # For removeFile

proc main() =
  echo "--- FileStream Operations ---"
  # TODO: Step 1 - FileStream: Write to a temporary file
  # 1a. Get a temporary file path using `newTempFile()`. Store its path.
  # 1b. Open a FileStream for writing (`fmWrite`) to this path.
  # 1c. Write at least three distinct lines of text/data to the stream.
  #     (e.g., "Name: Test User", "ID: 123", "Value: 3.14")
  # 1d. Close the stream.
  # 1e. Print a message like "Writing data to a temporary file..."
  # 1f. Print "Content written to file:" followed by the exact lines you wrote.
  #     Use `defer` or a `try/finally` block to ensure the stream is closed
  #     and the temporary file is eventually removed, even if errors occur.
  echo "FileStream write: Not implemented." # Placeholder

  # TODO: Step 2 - FileStream: Read from the temporary file
  # 2a. Open a FileStream for reading (`fmRead`) from the same temporary file path.
  # 2b. Read the lines back from the stream.
  # 2c. Close the stream.
  # 2d. Print a message like "Reading data from the temporary file..."
  # 2e. Print "Content read from file:" followed by the lines you read.
  # 2f. Remove the temporary file using `os.removeFile()`.
  # 2g. Print "Temporary file operations complete."
  #     Ensure stream closing and file removal happen reliably.
  echo "FileStream read and cleanup: Not implemented." # Placeholder


  echo "--- StringStream Operations ---"
  # TODO: Step 3 - StringStream: Build a string in memory
  # 3a. Create a new StringStream.
  # 3b. Write a combination of strings and other data types (e.g., integers) to it.
  #     (e.g., "Report for item_", "item_abc", ": status ", "OK", ", count ", 25)
  # 3c. Print a message like "Building string with StringStream..."
  # 3d. Retrieve the complete string from the StringStream using `.data`.
  # 3e. Print "StringStream result: " followed by the retrieved string.
  echo "StringStream operations: Not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()
