# Description: Practice recursion on data structures like sequences.
# Hint: For a sequence `s`, a recursive sum could be `s[0] + sum(s[1..^1])`.
# The base case is an empty sequence, for which the sum is 0.
# Slicing `s[1..^1]` creates a new sequence; be mindful of performance for very large sequences in real code.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a recursive function `sumRecursive` that takes a sequence of integers `items`.
#    - If `items` is empty (base case), it should return 0.
#    - Otherwise (recursive step), it should return `items[0] + sumRecursive(items[1..^1])`.
#      (Note: `items[1..^1]` is a slice from the second element to the end).
# 2. In `main`, calculate and print the sum of `@ [1, 2, 3, 4, 5]` using `sumRecursive`.
# 3. Calculate and print the sum of an empty sequence `@ []`.

# TODO: Step 1 - Define the recursive sumRecursive function here.
# proc sumRecursive(items: seq[int]): int =
#   ...

proc main() =
  # TODO: Step 2 - Call sumRecursive with a populated sequence.
  let numbers = @[1, 2, 3, 4, 5]
  # echo "Sum of ", numbers, ": ", sumRecursive(numbers)
  echo "Sum of populated sequence not implemented." # Placeholder

  # TODO: Step 3 - Call sumRecursive with an empty sequence.
  let emptySeq: seq[int] = @[]
  # echo "Sum of ", emptySeq, ": ", sumRecursive(emptySeq)
  echo "Sum of empty sequence not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Sum of @[1, 2, 3, 4, 5]: 15
# Sum of @[]: 0
# ```
