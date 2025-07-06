# Description: Learn to generate JSON strings from Nim data structures using the `json` module.
# Hint: `import json`. Use `newJObject()` to create a JsonNode of kind object.
# Add fields with `myJsonNode["fieldName"] = newJString("value")` or `newJInt(123)`, etc.
# The `%*` operator can convert basic Nim types and objects to JsonNode: `let jNode = %*myObject`.
# Convert a JsonNode to string with `$jNode` (compact) or `jNode.pretty()` (formatted).
# SandboxPreference: wasm
# Points: 15

import json

# Task:
# 1. Create a Nim object or Table representing a book:
#    `title = "Learning Nim"`
#    `pages = 300`
#    `authors = @["Author A", "Author B"]` (a sequence for the authors)
# 2. Convert this Nim data into a `JsonNode`.
#    You can do this by building a `JsonNode` manually using `newJObject()` and adding fields,
#    or by defining an object and using `%*` if you define the object type first.
#    Let's guide towards manual construction for this exercise to show `newJString`, `newJInt`, `newJArray`.
# 3. Convert the `JsonNode` to a pretty-printed JSON string and print it.

# Optional: Define a Book object type for easier conversion with %*
# type Book = object
#   title: string
#   pages: int
#   authors: seq[string]

proc main() =
  # TODO: Step 1 (Data is provided conceptually, focus on step 2 & 3)
  let title = "Learning Nim"
  let pages = 300
  let authors = @["Author A", "Author B"]

  # TODO: Step 2 - Convert Nim data to JsonNode (manual construction)
  # var bookJson = newJObject()
  # bookJson["title"] = newJString(title)
  # bookJson["pages"] = newJInt(pages)
  # var authorsArray = newJArray()
  # for author in authors:
  #   authorsArray.add(newJString(author))
  # bookJson["authors"] = authorsArray
  var bookJson: JsonNode = nil # Placeholder
  echo "JSON generation not implemented." # Placeholder

  # TODO: Step 3 - Convert JsonNode to pretty string and print
  # if bookJson != nil:
  #   echo bookJson.pretty()
  # else:
  #   echo "JsonNode is nil."


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# {
#   "authors": [
#     "Author A",
#     "Author B"
#   ],
#   "pages": 300,
#   "title": "Learning Nim"
# }
# ```
# Note: Field order in JSON objects is not guaranteed, but `pretty` often sorts them.
# The test should be flexible to order or ensure the Nim test uses a sorted Table for %* if that path chosen.
# For manual construction as guided, the order might be more predictable from the `add` calls if json module preserves it.
# The given ExpectedOutput implies alphabetical sorting of keys by `pretty`.
