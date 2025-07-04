import json
import os
import ospaths

const AppName = "Nimlings"
const StateFileName = "state.json"

type
  UserState* = object
    completedExercises*: seq[string]
    points*: int

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
      result = fromJsonStr[UserState](data)
      # If `points` was missing in JSON, it should be initialized to 0 by default by Nim's object construction.
      # No explicit check needed unless we want to log migration.
    except JsonParsingError as e:
      echo "Warning: Could not parse state file: ", e.msg, ". Starting with a fresh state."
      result = UserState(completedExercises: @[], points: 0)
    except IOError:
      echo "Warning: Could not read state file. Starting with a fresh state."
      result = UserState(completedExercises: @[], points: 0)
  else:
    # New user, fresh state
    result = UserState(completedExercises: @[], points: 0)

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
