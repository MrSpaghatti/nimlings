
import json, os, sets

type
  Progress* = object
    completed*: HashSet[string]

const
  ConfigDir = getHomeDir() / ".config" / "nimlings"
  ProgressFile = ConfigDir / "progress.json"
  StateFile = ConfigDir / "state.json"

proc ensureConfigDir*() =
  createDir(ConfigDir)

proc loadProgress*(): HashSet[string] =
  result = initHashSet[string]()
  if not fileExists(ProgressFile):
    return

  try:
    let data = parseJson(readFile(ProgressFile))
    for item in data.getElems():
      result.incl(item.getStr())
  except:
    discard

proc saveProgress*(completed: HashSet[string]) =
  ensureConfigDir()
  let jsonNode = newJArray()
  for item in completed:
    jsonNode.add(newJString(item))
  writeFile(ProgressFile, $jsonNode)

proc loadState*(): JsonNode =
  if not fileExists(StateFile):
    return newJObject()
  try:
    return parseJson(readFile(StateFile))
  except:
    return newJObject()

proc saveState*(lessonId: string) =
  ensureConfigDir()
  let jsonNode = %* {"last_lesson": lessonId}
  writeFile(StateFile, $jsonNode)
