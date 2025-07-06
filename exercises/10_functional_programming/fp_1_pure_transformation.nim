# Description: Understand pure functions: they always produce the same output for the same input and have no side effects.
# Hint: A pure function should not modify its input parameters (unless they are `var` and it's explicit,
# but for FP style, prefer returning new values). It also shouldn't modify global state or do I/O.
# SandboxPreference: wasm
# Points: 10

# Task:
# 1. Define a PURE function `incrementAll` that takes a sequence of integers `originalSeq`.
#    It must return a NEW sequence where each element is the corresponding element
#    from `originalSeq` incremented by 1.
#    The `originalSeq` itself MUST NOT be changed by this function.
# 2. In `main`, create a sample sequence. Call `incrementAll` with it.
# 3. Print both the original sequence (to show it's unchanged) and the new, incremented sequence.

# TODO: Step 1 - Define the pure function incrementAll here.
# proc incrementAll(originalSeq: seq[int]): seq[int] =
#   var newSeq = newSeq[int](originalSeq.len) # Or initialize empty and add
#   # ... your logic ...
#   return newSeq

proc main() =
  let numbers = @[10, 20, 30, 40]
  echo "Original: ", numbers

  # TODO: Step 2 - Call incrementAll
  # let incrementedNumbers = incrementAll(numbers)
  let incrementedNumbers: seq[int] = @[] # Placeholder
  echo "Incremented: ", incrementedNumbers # Placeholder for user's result

  # TODO: Step 3 - Verify original is unchanged (already done by printing `numbers` first if task 2 is correct)
  # The first echo of `numbers` and then printing `incrementedNumbers` (the result of pure function)
  # and then if we were to print `numbers` again, it should be the same as the first print.
  # For this exercise, simply printing original and then the result of the pure function is enough.

  echo "Pure function call not fully implemented." # Placeholder if TODOs aren't filled

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Original: @[10, 20, 30, 40]
# Incremented: @[11, 21, 31, 41]
# ```
