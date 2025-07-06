# Description: Introduction to Dynamic Programming: Memoization (Top-Down).
# Solve problems by breaking them into subproblems and storing their results to avoid re-computation.
# Hint: For Fibonacci, F(n) = F(n-1) + F(n-2). A naive recursive solution is very slow
# due to re-calculating the same F(k) multiple times.
# Memoization uses a table (e.g., array or Table) to store results of F(k) once computed.
# Before computing F(k), check if it's already in the table.
# SandboxPreference: wasm
# Points: 20

import tables # For Table as a memoization cache

# Naive recursive Fibonacci (for comparison, can be very slow)
# proc fibNaive(n: int): int =
#   if n <= 1: return n
#   return fibNaive(n-1) + fibNaive(n-2)

# Task:
# 1. Create a `memo` table (e.g., `Table[int, int]`) to store computed Fibonacci values.
# 2. Define a function `fibMemo(n: int, memo: var Table[int, int]): int`.
#    - Base cases: If n <= 1, return n.
#    - Memoization check: If `n` is already in `memo`, return `memo[n]`.
#    - Recursive step: Calculate `result = fibMemo(n-1, memo) + fibMemo(n-2, memo)`.
#    - Store result: `memo[n] = result`.
#    - Return `result`.
# 3. In `main`, initialize the memo table. Call `fibMemo` for a few values (e.g., 10, 20, 30)
#    and print the results.

# TODO: Step 1 & 2 - Define fibMemo function and its memoization logic.
# proc fibMemo(n: int, memo: var Table[int, int]): int =
#   ...

proc main() =
  var memo = initTable[int, int]()
  # Note: For some base cases like F(0)=0, F(1)=1, you might pre-populate memo,
  # or handle them directly in the fibMemo function before table lookup.
  # The hint suggests base cases n<=1 return n, so memo lookup for these isn't strictly needed
  # if the function handles them first.

  # TODO: Step 3 - Call fibMemo and print results.
  # echo "fibMemo(10) = ", fibMemo(10, memo)
  # memo.clear() # Clear memo for next independent test if needed, or use separate memos.
  # For this exercise, one memo is fine if we call with increasing N or it doesn't matter.
  # Let's assume one memo is used and builds up.

  # echo "fibMemo(20) = ", fibMemo(20, memo)
  # echo "fibMemo(30) = ", fibMemo(30, memo) # This would be very slow with naive recursion

  echo "Fibonacci with memoization not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# fibMemo(10) = 55
# fibMemo(20) = 6765
# fibMemo(30) = 832040
# ```
