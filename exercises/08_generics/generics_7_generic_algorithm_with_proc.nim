# Description: Implement a generic algorithm that takes a comparison procedure as a parameter.
# Hint: This allows the algorithm to work on types that don't have built-in comparison
# operators or when custom comparison logic is needed.
# Example: `proc mySort[T](s: var seq[T], lessThan: proc(a,b:T):bool) = ...`
# SandboxPreference: wasm
# Points: 25

import options # For Option[T]

# Task:
# 1. Define a generic function `findExtremum[T](items: seq[T], isBetter: proc(candidate, currentBest: T): bool): Option[T]`.
#    - This function should iterate through the `items` sequence.
#    - It uses the `isBetter` proc to determine if a `candidate` element is "better" (e.g., smaller or larger)
#      than the `currentBest` element found so far.
#    - If `items` is empty, it should return `none[T]()`.
#    - Otherwise, it should initialize `currentBest` with the first element and then iterate from the second,
#      updating `currentBest` if `isBetter(item, currentBest)` is true. Finally, return `some(currentBest)`.
# 2. In `main`:
#    a. Define a sequence of integers.
#    b. Call `findExtremum` to find the maximum element (provide an `isBetter` proc for `a > b`). Print the result.
#    c. Call `findExtremum` to find the minimum element (provide an `isBetter` proc for `a < b`). Print the result.
#    d. Define a sequence of strings.
#    e. Call `findExtremum` to find the longest string (provide an `isBetter` proc based on `len`). Print the result.

# TODO: Step 1 - Define generic function findExtremum[T]

proc main() =
  let numbers = @[3, 1, 4, 1, 5, 9, 2, 6]
  echo "Numbers: ", numbers

  # TODO: Step 2b - Find maximum number
  # let maxNum = findExtremum(numbers, proc(a,b: int): bool = a > b)
  # echo "Max number: ", maxNum
  echo "Max number not implemented." # Placeholder

  # TODO: Step 2c - Find minimum number
  # let minNum = findExtremum(numbers, proc(a,b: int): bool = a < b)
  # echo "Min number: ", minNum
  echo "Min number not implemented." # Placeholder

  let words = @["nim", "is", "awesome", "truly"]
  echo "Words: ", words
  # TODO: Step 2e - Find longest string
  # let longestWord = findExtremum(words, proc(a,b: string): bool = a.len > b.len)
  # echo "Longest word: ", longestWord
  echo "Longest word not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Numbers: @[3, 1, 4, 1, 5, 9, 2, 6]
# Max number: Some(9)
# Min number: Some(1)
# Words: @["nim", "is", "awesome", "truly"]
# Longest word: Some(awesome)
# ```
