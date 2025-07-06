# Description: Learn to define generic object types that can hold data of any type.
# Hint: Use `[T]` after the object name: `type MyContainer[T] = object data: T`.
# When creating instances, you might need to specify the type if it can't be inferred:
# `var intContainer = MyContainer[int](data: 10)` or let inference work `var strContainer = MyContainer(data: "hi")`.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a generic object type `Container[T]` with a single field `data` of type `T`.
# 2. Define a generic procedure `initContainer[T](value: T): Container[T]` that takes a `value`
#    and returns a `Container[T]` instance with its `data` field initialized to `value`.
# 3. Define a generic procedure `getValue[T](c: Container[T]): T` that returns the `data` from a `Container`.
# 4. In `main`:
#    a. Create a `Container[int]` using `initContainer` with an integer value. Get and print its value.
#    b. Create a `Container[string]` using `initContainer` with a string value. Get and print its value.

# TODO: Step 1 - Define generic object Container[T]

# TODO: Step 2 - Define generic proc initContainer[T]

# TODO: Step 3 - Define generic proc getValue[T]

proc main() =
  # TODO: Step 4a - Integer container
  # let intContainer = initContainer(123)
  # echo "Int container value: ", getValue(intContainer)
  echo "Int container not implemented." # Placeholder

  # TODO: Step 4b - String container
  # let stringContainer = initContainer("Nim Generics")
  # echo "String container value: ", getValue(stringContainer)
  echo "String container not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Int container value: 123
# String container value: Nim Generics
# ```
