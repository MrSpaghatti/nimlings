# Description: Parse more complex JSON structures like arrays and nested objects.
# Hint: `import json`. For a `JsonNode` that is an array, iterate with `for item in jsonArray:`.
# Each `item` will be a `JsonNode`. Access nested fields like `outerNode["parent"]["child"]`.
# Remember to use `.getStr()`, `.getInt()`, etc., and handle potential errors.
# SandboxPreference: wasm
# Points: 20

import json

# Task:
# 1. Given JSON string 1: `[{"name": "apple", "color": "red"}, {"name": "banana", "color": "yellow"}]`
#    Parse it. Iterate through the array. For each object, print its name and color.
# 2. Given JSON string 2: `{"user": {"id": 101, "username": "nimcoder"}, "status": "active"}`
#    Parse it. Access and print `user.username` and `status`.

proc main() =
  let jsonArrayString = """[{"name": "apple", "color": "red"}, {"name": "banana", "color": "yellow"}]"""
  let jsonNestedObjectString = """{"user": {"id": 101, "username": "nimcoder"}, "status": "active"}"""

  echo "--- Parsing JSON Array ---"
  # TODO: Task 1 - Parse jsonArrayString and print details from each object in the array.
  # try:
  #   let arrNode = parseJson(jsonArrayString)
  #   for itemNode in arrNode: # arrNode should be JArray kind
  #     echo "Fruit: ", itemNode["name"].getStr(), ", Color: ", itemNode["color"].getStr()
  # except JsonParsingError, JsonKindError, KeyError as e:
  #   echo "Error processing JSON array: ", e.msg
  echo "JSON array parsing not implemented." # Placeholder

  echo "\n--- Parsing Nested JSON Object ---"
  # TODO: Task 2 - Parse jsonNestedObjectString and print nested details.
  # try:
  #   let nestedNode = parseJson(jsonNestedObjectString)
  #   echo "Username: ", nestedNode["user"]["username"].getStr()
  #   echo "Status: ", nestedNode["status"].getStr()
  # except JsonParsingError, JsonKindError, KeyError as e:
  #   echo "Error processing nested JSON object: ", e.msg
  echo "Nested JSON object parsing not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# --- Parsing JSON Array ---
# Fruit: apple, Color: red
# Fruit: banana, Color: yellow
#
# --- Parsing Nested JSON Object ---
# Username: nimcoder
# Status: active
# ```
