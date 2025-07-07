# Description: Practice constructing more complex JSON objects and arrays programmatically.
# Hint: `import json`.
# `JsonNode` of kind `JObject` can have other `JsonNode`s (including `JArray` or other `JObject`s) as values.
# `JsonNode` of kind `JArray` can contain other `JsonNode`s.
# Use `myJObject[fieldName] = childJNode` or `myJArray.add(childJNode)`.
# SandboxPreference: wasm
# Points: 20

import json

# Task:
# Construct a JsonNode that represents the following JSON structure:
# {
#   "course": "Nimlings Interactive Course",
#   "version": 1.0,
#   "modules": [
#     {"id": "01_variables", "title": "Variables and Data Types"},
#     {"id": "02_control_flow", "title": "Control Flow"}
#   ],
#   "instructor": {
#     "name": "Professor Nim",
#     "contact": "nim@example.com"
#   }
# }
# Then, print its pretty string representation.

proc main() =
  # TODO: Construct the complex JsonNode here.
  # Example for creating a module object:
  # var module1 = newJObject()
  # module1["id"] = newJString("01_variables")
  # module1["title"] = newJString("Variables and Data Types")
  #
  # Example for creating the modules array:
  # var modulesArray = newJArray()
  # modulesArray.add(module1)
  # ... add module2 ...
  #
  # Example for creating the main object:
  # var rootJson = newJObject()
  # rootJson["course"] = newJString("Nimlings Interactive Course")
  # ... add other fields and nested structures ...

  var complexJson: JsonNode = nil # Placeholder
  echo "Complex JSON construction not implemented." # Placeholder

  # TODO: Print the pretty string of your `complexJson` node.
  # if complexJson != nil:
  #   echo complexJson.pretty()
  # else:
  #   echo "JsonNode is nil."


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# {
#   "course": "Nimlings Interactive Course",
#   "instructor": {
#     "contact": "nim@example.com",
#     "name": "Professor Nim"
#   },
#   "modules": [
#     {
#       "id": "01_variables",
#       "title": "Variables and Data Types"
#     },
#     {
#       "id": "02_control_flow",
#       "title": "Control Flow"
#     }
#   ],
#   "version": 1.0
# }
# ```
# Note: The order of fields in the top-level object and in the "instructor" object
# might vary due to JSON object key ordering not being guaranteed (though `pretty` often sorts).
# The test should ideally be flexible to key order or the solution should construct
# in a way that leads to this specific order if possible (e.g. adding keys alphabetically if that's how `pretty` behaves).
# For this exercise, the given order is a target.
