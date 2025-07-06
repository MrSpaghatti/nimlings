# Description: Learn to read content from files.
# Hint: `readFile(filename)` reads the entire file into a string.
# `for line in lines(filename)` iterates over each line in a file.
# You'll need a sample file. For this exercise, create a file named `sample_read.txt`
# in this same directory (`exercises/09_file_io/`) with the following content:
#
# Line 1 of sample.
# Another line here.
# End of sample file.
#
# SandboxPreference: native
# Points: 15

# Task:
# 1. Read the entire content of `sample_read.txt` into a string and print it, prefixed with "Full content:\n".
# 2. Read `sample_read.txt` line by line. For each line, print it prefixed with "Line: ".

proc main() =
  let filename = "sample_read.txt" # Assumes it's in the same directory as the running exercise

  # TODO: Step 1 - Read and print full content
  # Make sure `sample_read.txt` exists with the specified content first!
  # try:
  #   let fullContent = readFile(filename)
  #   echo "Full content:\n", fullContent
  # except IOError:
  #   echo "Error: Could not read '", filename, "'. Did you create it with the correct content?"
  echo "Full content reading not implemented." # Placeholder

  echo "\n--- Line by Line ---" # Separator

  # TODO: Step 2 - Read and print line by line
  # try:
  #   for line in lines(filename):
  #     echo "Line: ", line
  # except IOError:
  #   echo "Error: Could not iterate lines in '", filename, "'. File missing or unreadable."
  echo "Line by line reading not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
# This test assumes `sample_read.txt` is created by the user as instructed.
# Nimlings test environment itself doesn't manage this external file.
when defined(testMode):
  # To make this testable in an automated environment where file creation by user isn't guaranteed,
  # we might need to temporarily create the file here for testMode, or the test runner would.
  # For now, this relies on the user having created it, or the test runner setting it up.
  # Let's simulate its creation for testMode to ensure ExpectedOutput is met.
  const testFilename = "sample_read.txt"
  let testFileContent = """Line 1 of sample.
Another line here.
End of sample file."""
  try:
    writeFile(testFilename, testFileContent)
    main()
    removeFile(testFilename) # Clean up
  except IOError:
    echo "Test setup error: Could not create/delete sample_read.txt for testing."
else:
  main() # User runs, assumes they created the file.

# ExpectedOutput: ```
# Full content:
# Line 1 of sample.
# Another line here.
# End of sample file.
#
# --- Line by Line ---
# Line: Line 1 of sample.
# Line: Another line here.
# Line: End of sample file.
# ```
