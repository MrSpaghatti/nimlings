# Description: Learn to handle potential errors gracefully using `try` and `except` blocks.
# Hint: `parseInt` from `strutils` can raise a `ValueError` if the string is not a valid integer.
# You can catch this with:
# try:
#   let num = "abc".parseInt()
# except ValueError:
#   echo "Could not parse integer!"
# SandboxPreference: wasm # Basic exception handling should work in WASM/WASI
# Points: 10

import strutils

# Task: Write a procedure `safeParseInt` that takes a string.
# - It should attempt to parse the string into an integer using `parseInt`.
# - If successful, it should print "Parsed number: [number]".
# - If a `ValueError` occurs, it should print "Error: Not a valid integer string."

proc safeParseInt*(s: string) =
  # TODO: Implement the try/except block here.
  echo "safeParseInt not implemented for: ", s # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  safeParseInt("123")
  safeParseInt("45x")
  safeParseInt("-5")
  safeParseInt("") # Empty string also causes ValueError
else:
  safeParseInt("test")
  safeParseInt("99")

# ExpectedOutput: ```
# Parsed number: 123
# Error: Not a valid integer string.
# Parsed number: -5
# Error: Not a valid integer string.
# ```
