# Description: Dynamic Programming: Tabulation (Bottom-Up).
# Solve Fibonacci by iteratively building up solutions from base cases.
# Hint: Create an array or sequence `dp` of size `n+1`.
# Initialize base cases: `dp[0] = 0`, `dp[1] = 1`.
# Then, iterate from 2 to `n`, calculating `dp[i] = dp[i-1] + dp[i-2]`.
# The result is `dp[n]`.
# SandboxPreference: wasm
# Points: 20

# Task:
# 1. Define a function `fibTab(n: int): int` that calculates Fibonacci using tabulation.
#    - Handle `n < 0` by perhaps returning an error indicator or raising an exception (for this exercise, let's assume n >= 0 and return 0 for n < 0 for simplicity, or adjust n range).
#      The problem is usually defined for non-negative n. Let's stick to n >= 0.
#    - If `n == 0`, return 0. If `n == 1`, return 1.
#    - Create a `dp` table (e.g., `var dp = newSeq[int](n + 1)`).
#    - Set `dp[0] = 0` and `dp[1] = 1`.
#    - Loop from `i = 2` to `n`, filling `dp[i]`.
#    - Return `dp[n]`.
# 2. In `main`, call `fibTab` for a few values (e.g., 10, 20, 30, 0, 1) and print the results.

# TODO: Step 1 - Define fibTab function here.
# proc fibTab(n: int): int =
#   ...

proc main() =
  # TODO: Step 2 - Call fibTab and print results.
  # echo "fibTab(10) = ", fibTab(10)
  # echo "fibTab(20) = ", fibTab(20)
  # echo "fibTab(30) = ", fibTab(30)
  # echo "fibTab(0) = ", fibTab(0)
  # echo "fibTab(1) = ", fibTab(1)

  echo "Fibonacci with tabulation not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# fibTab(10) = 55
# fibTab(20) = 6765
# fibTab(30) = 832040
# fibTab(0) = 0
# fibTab(1) = 1
# ```
