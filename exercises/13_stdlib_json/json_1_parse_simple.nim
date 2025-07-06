# Description: Learn to parse JSON strings into Nim data structures using the `json` module.
# Hint: `import json`. Use `parseJson(jsonString)` to get a `JsonNode`.
# Access fields of a JSON object: `myJsonNode["fieldName"]`.
# Convert JsonNode fields to Nim types: `.getInt()`, `.getStr()`, `.getFloat()`, etc.
# These can raise `JsonKindError` or `KeyError` if field missing/wrong type. Use `try/except`.
# SandboxPreference: wasm
# Points: 15

import json

# Task:
# 1. Given the JSON string: `{"name": "Nim Programming", "year": 2008, "isAwesome": true}`
# 2. Parse this string into a `JsonNode`.
# 3. Extract and print the "name" (string).
# 4. Extract and print the "year" (integer).
# 5. Extract and print the "isAwesome" (boolean).
# 6. Attempt to access a non-existent field "author" and handle the potential `KeyError`
#    by printing "Field 'author' not found."

proc main() =
  let jsonString = """{"name": "Nim Programming", "year": 2008, "isAwesome": true}"""
  echo "Original JSON string: ", jsonString

  # TODO: Step 2 - Parse jsonString
  # var jsonData: JsonNode
  # try:
  #   jsonData = parseJson(jsonString)
  # except JsonParsingError as e:
  #   echo "JSON Parsing Error: ", e.msg
  #   return
  echo "JSON parsing not implemented." # Placeholder

  # TODO: Step 3 - Extract and print "name"
  # try:
  #   echo "Name: ", jsonData["name"].getStr()
  # except KeyError, JsonKindError: # Catch either if field missing or wrong type
  #   echo "Error accessing 'name' field."
  echo "Name extraction not implemented." # Placeholder

  # TODO: Step 4 - Extract and print "year"
  # try:
  #   echo "Year: ", jsonData["year"].getInt()
  # except KeyError, JsonKindError:
  #   echo "Error accessing 'year' field."
  echo "Year extraction not implemented." # Placeholder

  # TODO: Step 5 - Extract and print "isAwesome"
  # try:
  #   echo "Is Awesome: ", jsonData["isAwesome"].getBool()
  # except KeyError, JsonKindError:
  #   echo "Error accessing 'isAwesome' field."
  echo "IsAwesome extraction not implemented." # Placeholder

  # TODO: Step 6 - Attempt to access "author" and handle KeyError
  # try:
  #   echo "Author: ", jsonData["author"].getStr() # This should fail
  # except KeyError:
  #   echo "Field 'author' not found."
  echo "Author field access attempt not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Original JSON string: {"name": "Nim Programming", "year": 2008, "isAwesome": true}
# Name: Nim Programming
# Year: 2008
# Is Awesome: true
# Field 'author' not found.
# ```
