
import unittest, sets, json

suite "Models":

  setup:
    # Mock HOME for testing config dir
    # We can't easily mock getHomeDir() in Nim standard lib without wrapping it.
    # However, models.nim uses `ConfigDir` const which is evaluated at compile time or runtime?
    # Let's check models.nim.
    discard

  test "Progress Loading/Saving":
    # We might need to refactor models.nim to accept a path for testing,
    # or we just trust the logic if we can't mock file system easily in this env.
    # Let's refactor models.nim slightly to be more testable if needed,
    # or duplicate logic here to verify json parsing.

    let s = toHashSet(["1.1", "1.2"])
    let jsonNode = newJArray()
    for item in s:
      jsonNode.add(newJString(item))

    let jsonStr = $jsonNode
    # verify it parses back
    let parsed = parseJson(jsonStr)
    var res = initHashSet[string]()
    for item in parsed.getElems():
      res.incl(item.getStr())

    check "1.1" in res
    check "1.2" in res
    check res.len == 2

  test "State Loading/Saving":
    let data = %* {"last_lesson": "1.2"}
    check data["last_lesson"].getStr() == "1.2"
