import json
import os
import ospaths

const AppName = "Nimlings"
const StateFileName = "state.json"

type
  UserState* = object
    completedExercises*: seq[string]
    # We can add more fields here later, like points, badges, etc.

proc getStateFilePath*(): string =
  var configDir = getConfigDir()
  # On Linux, this is typically ~/.config. On Windows, %APPDATA%. On macOS, ~/Library/Application Support.
  # We'll create a subdirectory for our application.
  result = configDir / AppName / StateFileName
  # Ensure the directory exists
  createDir(parentDir(result))

proc loadState*(): UserState =
  let stateFile = getStateFilePath()
  if fileExists(stateFile):
    try:
      let data = readFile(stateFile)
      result =fromJsonStr[UserState](data)
    except JsonParsingError:
      echo "Warning: Could not parse state file. Starting with a fresh state."
      # Fallback to default state if parsing fails
      result = UserState(completedExercises: @[])
    except IOError:
      echo "Warning: Could not read state file. Starting with a fresh state."
      result = UserState(completedExercises: @[])
  else:
    result = UserState(completedExercises: @[])

proc saveState*(state: UserState) =
  let stateFile = getStateFilePath()
  try:
    let data = toJson(state)
    writeFile(stateFile, data)
  except IOError:
    echo "Error: Could not write state file to " & stateFile

# Example usage (can be removed or put behind a `when isMainModule` block for testing)
when isMainModule:
  var state = loadState()
  echo "Loaded state: ", state.completedExercises

  if "exercises/01_variables/variables1.nim" notin state.completedExercises:
    state.completedExercises.add("exercises/01_variables/variables1.nim")

  saveState(state)
  echo "Saved state: ", state.completedExercises

  # Test loading it back
  let newState = loadState()
  echo "Reloaded state: ", newState.completedExercises
