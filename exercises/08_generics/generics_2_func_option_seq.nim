# Description: Create a generic function that operates on sequences of any type and uses `Option`.
# Hint: `import options`. An `Option[T]` can be `some(value: T)` or `none[T]()`.
# Use `isSome()` and `isNone()` to check, and `get()` to extract the value (if it's Some).
# SandboxPreference: wasm
# Points: 15

import options # For Option[T]

# Task:
# 1. Define a generic function `firstElement` that takes a sequence `items` of generic type `T`.
#    - If `items` is empty, the function should return `none[T]()`.
#    - Otherwise, it should return `some(items[0])`.
# 2. In `main`:
#    a. Create a sequence of integers `@ [10, 20, 30]`. Call `firstElement` and print the result
#       (e.g., "First int: Some(10)" or handle the Option).
#    b. Create an empty sequence of strings. Call `firstElement` and print the result
#       (e.g., "First string from empty: None").
#    c. Create a sequence of strings `@ ["hello", "world"]`. Call `firstElement` and print.

# TODO: Step 1 - Define the generic function firstElement[T] here.
# proc firstElement[T](items: seq[T]): Option[T] =
#   ...

proc main() =
  # TODO: Step 2a - Test with seq[int]
  let numbers = @[10, 20, 30]
  # let firstNumOpt = firstElement(numbers)
  # if firstNumOpt.isSome:
  #   echo "First int: Some(", firstNumOpt.get(), ")"
  # else:
  #   echo "First int: None" # Should not happen for this case
  echo "Int sequence test not implemented." # Placeholder

  # TODO: Step 2b - Test with empty seq[string]
  let emptyStrings: seq[string] = @[]
  # let firstEmptyOpt = firstElement(emptyStrings)
  # if firstEmptyOpt.isNone:
  #   echo "First string from empty: None"
  # else:
  #   echo "First string from empty: Some(", firstEmptyOpt.get(), ")" # Should not happen
  echo "Empty string sequence test not implemented." # Placeholder

  # TODO: Step 2c - Test with seq[string]
  let words = @["hello", "world"]
  # let firstWordOpt = firstElement(words)
  # # A different way to print Option: echo firstWordOpt
  # echo "First word option: ", firstWordOpt
  echo "String sequence test not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# First int: Some(10)
# First string from empty: None
# First word option: Some(hello)
# ```
