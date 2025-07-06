import os
import strutils
import tables
import re # For simple pattern matching if needed, though strutils might suffice

type
  ExerciseMetadata = object
    description: Option[string]
    hint: Option[string]
    points: Option[int]
    sandboxPreference: Option[string]
    expectedOutput: Option[string]
    validationScript: Option[string]
    # Add more fields for optional checks later if needed (e.g., tags, difficulty)

proc parseMetadata(filePath: string): ExerciseMetadata =
  result = ExerciseMetadata() # All options are none initially
  var inExpectedOutputBlock = false
  var currentExpectedOutputLines: seq[string]

  try:
    for line in lines(filePath):
      let strippedLine = line.strip()

      if inExpectedOutputBlock:
        if strippedLine == "# ```":
          inExpectedOutputBlock = false
          result.expectedOutput = some(currentExpectedOutputLines.join("\n"))
        else:
          # Remove leading "# " or "#"
          if strippedLine.startsWith("# "):
            currentExpectedOutputLines.add(strippedLine[2..^1])
          elif strippedLine.startsWith("#"):
            currentExpectedOutputLines.add(strippedLine[1..^1])
          else: # Should not happen if correctly formatted
            currentExpectedOutputLines.add(strippedLine)
        continue # Continue to next line once in block or block ends

      if strippedLine.startsWith("# Description:"):
        result.description = some(strippedLine.split(":", 1)[1].strip())
      elif strippedLine.startsWith("# Hint:"):
        result.hint = some(strippedLine.split(":", 1)[1].strip())
      elif strippedLine.startsWith("# Points:"):
        try:
          result.points = some(parseInt(strippedLine.split(":", 1)[1].strip()))
        except ValueError:
          result.points = none[int]() # Mark as parse error later or handle here
          echo "Warning: Could not parse Points value in ", filePath
      elif strippedLine.startsWith("# SandboxPreference:"):
        result.sandboxPreference = some(strippedLine.split(":", 1)[1].strip().toLower())
      elif strippedLine.startsWith("# ExpectedOutput:"):
        let val = strippedLine.split(":", 1)[1].strip()
        if val == "```":
          inExpectedOutputBlock = true
          currentExpectedOutputLines = @[] # Reset for new block
        else:
          result.expectedOutput = some(val)
      elif strippedLine.startsWith("# ValidationScript:"):
        result.validationScript = some(strippedLine.split(":", 1)[1].strip())
  except IOError:
    echo "Error reading file: ", filePath

  # If ExpectedOutput block was started but not closed (EOF)
  if inExpectedOutputBlock and result.expectedOutput.isNone and currentExpectedOutputLines.len > 0:
    result.expectedOutput = some(currentExpectedOutputLines.join("\n"))


proc validateMetadata(filePath: string, meta: ExerciseMetadata): seq[string] =
  var errors: seq[string]

  if meta.description.isNoneOrEmpty: errors.add("Missing or empty # Description.")
  if meta.hint.isNoneOrEmpty: errors.add("Missing or empty # Hint.")

  if meta.points.isNone: errors.add("Missing or invalid # Points (must be an integer).")
  elif meta.points.get <= 0: errors.add("# Points must be positive.")

  if meta.sandboxPreference.isNoneOrEmpty: errors.add("Missing or empty # SandboxPreference.")
  elif meta.sandboxPreference.get notin ["wasm", "native"]:
    errors.add("Invalid # SandboxPreference: '" & meta.sandboxPreference.get & "'. Must be 'wasm' or 'native'.")

  let hasExpectedOutput = meta.expectedOutput.isSome and meta.expectedOutput.get.strip().len > 0
  let hasValidationScript = meta.validationScript.isSome and meta.validationScript.get.strip().len > 0

  if not (hasExpectedOutput or hasValidationScript):
    errors.add("Missing either # ExpectedOutput (with content) or # ValidationScript.")

  if meta.validationScript.isSome and not meta.validationScript.get.endsWith(".nims"):
    errors.add("# ValidationScript filename '" & meta.validationScript.get & "' does not look like a .nims script.")

  return errors

proc main() =
  let exercisesRoot = "." / "exercises" # Adjust if script is run from a different root
  var totalFilesChecked = 0
  var totalErrorsFound = 0

  echo "Starting Exercise Metadata Check in '", exercisesRoot, "'..."

  # Exclude specific non-exercise files if any (e.g. myutils.nim if it's in a topic dir)
  let excludedFiles = ["myutils.nim"]

  for dirPath in walkDirRec(exercisesRoot, yieldFilter={pcDir}):
    for filePath in walkDirRec(dirPath, yieldFilter={pcFile}):
      if filePath.endsWith(".nim"):
        if extractFilename(filePath) in excludedFiles:
          echo "Skipping non-exercise file: ", filePath
          continue

        totalFilesChecked += 1
        echo "\nChecking: ", filePath
        let metadata = parseMetadata(filePath)
        let errors = validateMetadata(filePath, metadata)

        if errors.len > 0:
          totalErrorsFound += errors.len
          for err in errors:
            echo "  ERROR: ", err
        else:
          echo "  OK."

  echo "\n--- Check Complete ---"
  echo "Total Files Checked: ", totalFilesChecked
  echo "Total Metadata Errors Found: ", totalErrorsFound

  if totalErrorsFound > 0:
    quit(1) # Exit with error code for CI

main()
