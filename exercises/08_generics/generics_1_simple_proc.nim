# Description: Learn to create generic procedures that work with any data type.
# Hint: Use `[T]` (or any other letter) after the proc name to declare a generic type parameter.
# `proc myGeneric[T](param: T) = echo param`
# The compiler will create a version of the proc for each type it's called with.
# SandboxPreference: wasm
# Points: 10

# Task:
# 1. Define a generic procedure named `printTwice` that takes one parameter `value` of a generic type `T`.
#    This procedure should print the `value` two times, each on a new line.
# 2. In `main`, call `printTwice` with an integer (e.g., 5).
# 3. Call `printTwice` with a string (e.g., "Nim").
# 4. Call `printTwice` with a float (e.g., 3.14).

# TODO: Step 1 - Define the generic procedure printTwice[T] here.
# proc printTwice[T](value: T) =
#   ...
#   ...

proc main() =
  # TODO: Step 2, 3, 4 - Call printTwice with different types.
  echo "Generic procedure calls not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# 5
# 5
# Nim
# Nim
# 3.14
# 3.14
# ```
