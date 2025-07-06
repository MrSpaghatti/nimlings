# Description: Learn about path normalization and finding files using glob patterns with the `os` module.
# Hint: `import os`.
# `normalizePath(path)` cleans up a path (e.g., `a/./b//c` -> `a/b/c`).
# `expandGlob(pattern)` returns a sequence of paths matching the glob pattern (e.g., `*.txt`).
# `walkPattern(pattern)` is an iterator that yields matching paths (can be more memory efficient).
# For this exercise, we'll use `expandGlob` for simplicity.
# SandboxPreference: native
# Points: 15

import os
import strutils # For sorting results for predictable output

# Task:
# 1. Given a messy path like "my/../path/./to/./file.txt", normalize it and print the result.
# 2. In a temporary test directory (created in `testMode`):
#    a. Create files: "report_final.txt", "report_draft.txt", "summary.md", "image.png".
#    b. Use `expandGlob` to find all ".txt" files in this directory.
#    c. Sort the found .txt files (for predictable output) and print them.
#    d. Use `expandGlob` to find all files starting with "report_" and ending with ".txt".
#    e. Sort these found files and print them.

proc main() =
  # TODO: Task 1 - Normalize a path
  let messyPath = "my/../path/./to/./file.txt" # On Windows, this might resolve differently if "my" doesn't exist.
                                             # normalizePath primarily deals with ., .., and slashes.
  # let normalized = normalizePath(messyPath)
  # echo "Messy path: ", messyPath
  # echo "Normalized: ", normalized
  echo "Path normalization not implemented." # Placeholder

  echo "\n--- Globbing ---"
  let tempDir = "glob_test_dir"

  # Task 2 setup (files created in testMode block below)
  # TODO: Task 2b - Find all .txt files
  # let txtFilesPattern = tempDir / "*.txt"
  # var foundTxtFiles = expandGlob(txtFilesPattern).sorted(system.cmp) # Sort for predictable output
  # echo "Found .txt files: ", foundTxtFiles
  echo "Glob for *.txt not implemented." # Placeholder

  # TODO: Task 2d - Find report_*.txt files
  # let reportPattern = tempDir / "report_*.txt"
  # var foundReportFiles = expandGlob(reportPattern).sorted(system.cmp)
  # echo "Found report_*.txt files: ", foundReportFiles
  echo "Glob for report_*.txt not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  let tempDir = "glob_test_dir"
  try:
    createDir(tempDir)
    writeFile(tempDir / "report_final.txt", "final report")
    writeFile(tempDir / "report_draft.txt", "draft report")
    writeFile(tempDir / "summary.md", "summary")
    writeFile(tempDir / "image.png", "png data")

    main()

  finally:
    # Teardown
    let filesToClean = @["report_final.txt", "report_draft.txt", "summary.md", "image.png"]
    for fName in filesToClean:
      if fileExists(tempDir / fName): removeFile(tempDir / fName)
    if dirExists(tempDir): removeDir(tempDir)
else:
  echo "Manual run: Create a directory 'glob_test_dir' with files like"
  echo "'report_final.txt', 'report_draft.txt', 'summary.md', 'image.png' to test globbing."
  main()

# ExpectedOutput: ```
# Messy path: my/../path/./to/./file.txt
# Normalized: path/to/file.txt
#
# --- Globbing ---
# Found .txt files: @["glob_test_dir/report_draft.txt", "glob_test_dir/report_final.txt"]
# Found report_*.txt files: @["glob_test_dir/report_draft.txt", "glob_test_dir/report_final.txt"]
# ```
# Note: `normalizePath("my/../path/./to/./file.txt")` on Unix-like systems results in "path/to/file.txt".
# On Windows, if "my" does not exist in CWD, it might remain "my/../path/to/file.txt" or similar.
# The ExpectedOutput assumes Unix-like normalization or that `my` is not a real existing dir.
# For consistency, the exercise focuses on ., .., and slashes which normalizePath handles well cross-platform.
# The `glob_test_dir` part of the path in ExpectedOutput assumes the script/test runs from one level above `glob_test_dir`.
# If `expandGlob` returns paths relative to CWD, and CWD is where `glob_test_dir` is, then it's fine.
# `os.getCurrentDir()` inside the test setup could make paths absolute for more robust `expandGlob` testing if needed.
# For now, assuming `expandGlob` works relative to CWD where `tempDir` is created.
