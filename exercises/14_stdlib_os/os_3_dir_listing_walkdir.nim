# Description: Learn to list contents of a directory and walk directory trees using `os.walkDir`.
# Hint: `import os`. `walkDir(path)` returns an iterator yielding tuples `(kind: PathComponent, path: string)`.
# `PathComponent` can be `pcFile`, `pcDir`, `pcLinkToFile`, `pcLinkToDir`.
# You'll need a small directory structure for testing.
# SandboxPreference: native
# Points: 15

import os

# Task:
# 1. Create a procedure `listDirectoryContents(dirPath: string)` that:
#    a. Prints "Contents of [dirPath]:"
#    b. Uses `walkDir` to iterate ONLY the immediate contents (not recursive) of `dirPath`.
#       (Hint: `walkDir` yields items. You might need to break after processing immediate children,
#        or check the depth, but for a flat list, a simple `for` loop over `walkDir` on the
#        target dir is fine if it doesn't recurse by default on simple iteration.
#        Actually, `os.walkDir` is recursive by default. To list only immediate contents,
#        one would typically use `os.walkFiles` or `os.walkDirs` iterators or check paths.
#        A simpler approach for listing immediate contents might be `for kind, item in listDir(dirPath):`.
#        However, `listDir` is deprecated. `walkDir` is preferred.
#        Let's make the task to print all files (recursively) for simplicity with `walkDir`.
#        Task changed: Print all *files* found recursively within `dirPath`, showing their full paths.
# 2. In `main`, call `listDirectoryContents` with a test directory path.
# The `testMode` block will create a sample directory structure.

# TODO: Step 1 - Define listDirectoryContents procedure.
# proc listDirectoryContents(dirPath: string) =
#   echo "Files found in or under '", dirPath, "':"
#   var foundFiles = false
#   for kind, path in walkDir(dirPath):
#     if kind == pcFile:
#       echo path # path is usually absolute or relative to invocation, ensure it's what's expected
#       foundFiles = true
#   if not foundFiles:
#     echo "(No files found)"


proc main() =
  let testDirPath = "sample_dir_tree" # Test directory will be created in testMode

  # TODO: Step 2 - Call listDirectoryContents.
  # listDirectoryContents(testDirPath)
  echo "Directory listing not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  let baseTestDir = "sample_dir_tree"
  try:
    # Create structure:
    # sample_dir_tree/
    #   file1.txt
    #   subdir/
    #     file2.txt
    #     file3.dat
    createDir(baseTestDir)
    writeFile(baseTestDir / "file1.txt", "content1")
    createDir(baseTestDir / "subdir")
    writeFile(baseTestDir / "subdir" / "file2.txt", "content2")
    writeFile(baseTestDir / "subdir" / "file3.dat", "content3")

    main()

  finally:
    # Teardown: Clean up dummy directory structure
    if dirExists(baseTestDir / "subdir"):
      if fileExists(baseTestDir / "subdir" / "file2.txt"): removeFile(baseTestDir / "subdir" / "file2.txt")
      if fileExists(baseTestDir / "subdir" / "file3.dat"): removeFile(baseTestDir / "subdir" / "file3.dat")
      removeDir(baseTestDir / "subdir")
    if fileExists(baseTestDir / "file1.txt"): removeFile(baseTestDir / "file1.txt")
    if dirExists(baseTestDir): removeDir(baseTestDir)
else:
  echo "Manual run: Create a directory 'sample_dir_tree' with some files and subdirectories to test."
  main()

# ExpectedOutput: ```
# Files found in or under 'sample_dir_tree':
# sample_dir_tree/file1.txt
# sample_dir_tree/subdir/file2.txt
# sample_dir_tree/subdir/file3.dat
# ```
# Note: Order of files from walkDir might vary by OS. The test should be flexible or sort results.
# For this ExpectedOutput, I'll assume a consistent (e.g., alphabetical) order or make the test check for presence.
# Let's assume the output paths will include the baseTestDir. If `walkDir` gives absolute paths,
# the ExpectedOutput would need to be different or paths normalized.
# `walkDir` yields paths relative to the current directory if its argument is relative.
# If main calls listDirectoryContents("sample_dir_tree"), paths will be relative to where nimlings runs.
# The test setup creates "sample_dir_tree" in current dir. So paths should be like "sample_dir_tree/file.txt". This is fine.
# The default order from `walkDir` is OS-dependent. For predictable `ExpectedOutput`, we should sort.
# The example solution will collect paths and sort them before printing for the test.
