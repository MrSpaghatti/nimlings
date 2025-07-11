# Description: Use `std/parseutils` to parse a string containing key-value pairs (e.g., "key1=val1;key2=val2"), attempting to convert values to int or bool where appropriate.
# Hint: Iterate through the input string using a position variable `i`. In each step, use `parseIdent(s, key, i)` for the key, `skipChar(s, '=', i)` for '=', and `parseUntil(s, valueStr, ';', i)` for the value string (or parse until end of string for the last value). Then, inspect the `valueStr`: try `strutils.parseInt()`, check for "true"/"false", otherwise it's a string. Remember `parseUntil` doesn't consume the separator, so you might need `skipChar(s, ';', i)` after parsing the value if it's not the last pair.
# Points: 35
# SandboxPreference: wasm
# ExpectedOutput: ```
# Parsing: name=Alice;age=30;active=true;score=123
# Key: "name", Value: "Alice" (string)
# Key: "age", Value: 30 (int)
# Key: "active", Value: true (bool)
# Key: "score", Value: 123 (int)
# ---
# Parsing: item=Desk;width=120;enabled=false;notes=Urgent Review
# Key: "item", Value: "Desk" (string)
# Key: "width", Value: 120 (int)
# Key: "enabled", Value: false (bool)
# Key: "notes", Value: "Urgent Review" (string)
# ```

import std/parseutils
import std/strutils # For parseInt and toLowerAscii

proc parseAndPrintKVPairs(input: string) =
  echo "Parsing: ", input
  var i = 0 # Current parsing position

  # TODO: Loop while `i < input.len` to parse all key-value pairs.
  # In each iteration:
  # 1. Declare `key: string` and `valueStr: string`.
  # 2. Parse the key using `parseIdent(input, key, i)`. Handle potential errors if parseIdent fails (e.g., if input is malformed, though test cases are well-formed).
  # 3. Skip the '=' character using `skipChar(input, '=', i)`.
  # 4. Parse the value string. You can use `parseUntil(input, valueStr, ';', i)`.
  #    If `parseUntil` returns 0 (meaning separator not found), it means this might be the last value,
  #    so then parse until the end: `valueStr = input.substr(i)`. Update `i` to `input.len`.
  # 5. Attempt to convert `valueStr` to an integer.
  #    If successful, print `Key: "<key>", Value: <intValue> (int)`.
  # 6. Else, check if `valueStr.toLowerAscii()` is "true" or "false".
  #    If so, convert to bool and print `Key: "<key>", Value: <boolValue> (bool)`.
  # 7. Else, it's a string. Print `Key: "<key>", Value: "<valueStr>" (string)`.
  # 8. If not at the end of the string after parsing valueStr (i.e., if a ';' was found and consumed by parseUntil's logic, or if you parsed until ';'),
  #    try to `skipChar(input, ';', i)` to move past the separator for the next pair.
  #    Careful: `parseUntil` does NOT consume the separator. So you'll always need to skip ';' if it was the separator.

  # Example for one pair (you'll need a loop and more logic):
  if input.len > 0: # Basic check
    # This is a simplified placeholder for the complex loop logic described above.
    echo "Parsing logic not implemented."
    echo "Key: \"exampleKey\", Value: \"exampleValue\" (string)" # Placeholder output
  else:
    echo "Empty input string."


proc main() =
  let testString1 = "name=Alice;age=30;active=true;score=123"
  parseAndPrintKVPairs(testString1)

  echo "---"

  let testString2 = "item=Desk;width=120;enabled=false;notes=Urgent Review"
  parseAndPrintKVPairs(testString2)

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()
