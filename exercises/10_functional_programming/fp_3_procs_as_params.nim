# Description: Learn about higher-order functions: functions that take other functions as parameters.
# Hint: Define a proc parameter like `operation: proc(x: int): int`.
# This allows you to pass different behaviors (functions) to a single utility function.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a generic higher-order function `mapSeq[A, B](items: seq[A], transformOp: proc(item: A): B): seq[B]`.
#    This function should take a sequence `items` and a transformation procedure `transformOp`.
#    It should apply `transformOp` to each element in `items` and return a new sequence of the results.
# 2. In `main`:
#    a. Define a simple proc `doubleInt(x: int): int` that returns `x * 2`.
#    b. Define a simple proc `intToString(x: int): string` that returns ` "Num: " & $x`.
#    c. Create a sequence of integers `numbers = @[1, 2, 3]`.
#    d. Call `mapSeq` with `numbers` and `doubleInt`. Print the resulting sequence.
#    e. Call `mapSeq` with `numbers` and `intToString`. Print the resulting sequence.

# TODO: Step 1 - Define mapSeq[A, B] here.
# proc mapSeq[A, B](items: seq[A], transformOp: proc(item: A): B): seq[B] =
#   var result = newSeq[B]() # Or newSeq[B](items.len) and assign by index
#   for item in items:
#     result.add(transformOp(item))
#   return result

proc main() =
  # TODO: Step 2a - Define doubleInt
  # proc doubleInt(x: int): int = ...

  # TODO: Step 2b - Define intToString
  # proc intToString(x: int): string = ...

  let numbers = @[1, 2, 3]
  echo "Original numbers: ", numbers

  # TODO: Step 2d - Call mapSeq with doubleInt
  # let doubled = mapSeq(numbers, doubleInt)
  # echo "Doubled: ", doubled
  echo "mapSeq with doubleInt not implemented." # Placeholder

  # TODO: Step 2e - Call mapSeq with intToString
  # let stringified = mapSeq(numbers, intToString)
  # echo "Stringified: ", stringified
  echo "mapSeq with intToString not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Original numbers: @[1, 2, 3]
# Doubled: @[2, 4, 6]
# Stringified: @["Num: 1", "Num: 2", "Num: 3"]
# ```
