# Description: Define a generic object that can hold a pair of values of potentially different types.
# Hint: Use multiple generic parameters: `type MyPair[A, B] = object first: A, second: B`.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a generic object type `Pair[X, Y]` with two fields:
#    - `item1` of type `X`
#    - `item2` of type `Y`
# 2. Define a generic procedure `newPair[X, Y](val1: X, val2: Y): Pair[X, Y]` that creates and returns a Pair.
# 3. Define a generic procedure `displayPair[X, Y](p: Pair[X, Y])` that prints the pair in the format "(item1, item2)".
# 4. In `main`:
#    a. Create a `Pair[int, string]` and display it.
#    b. Create a `Pair[string, bool]` and display it.

# TODO: Step 1 - Define generic object Pair[X, Y]

# TODO: Step 2 - Define generic proc newPair[X, Y]

# TODO: Step 3 - Define generic proc displayPair[X, Y]

proc main() =
  # TODO: Step 4a - Integer and String pair
  # let pair1 = newPair(10, "Apple")
  # displayPair(pair1)
  echo "Int-String pair not implemented." # Placeholder

  # TODO: Step 4b - String and Bool pair
  # let pair2 = newPair("Status", true)
  # displayPair(pair2)
  echo "String-Bool pair not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# (10, Apple)
# (Status, true)
# ```
