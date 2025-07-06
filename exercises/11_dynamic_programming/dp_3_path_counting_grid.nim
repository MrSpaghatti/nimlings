# Description: Dynamic Programming: Path Counting on a Grid.
# Problem: Find the number of unique paths from the top-left corner (0,0)
# to the bottom-right corner (m-1, n-1) of an m x n grid.
# You can only move right or down.
# Hint: Use a 2D DP table `dp[row][col]` to store the number of ways to reach cell (row, col).
# Base cases: `dp[0][0] = 1` (one way to be at the start).
# For the first row (`dp[0][j]`), you can only reach it from the left: `dp[0][j] = dp[0][j-1]`. So, all `dp[0][j] = 1`.
# For the first column (`dp[i][0]`), you can only reach it from above: `dp[i][0] = dp[i-1][0]`. So, all `dp[i][0] = 1`.
# Recurrence relation for other cells: `dp[i][j] = dp[i-1][j] (from above) + dp[i][j-1] (from left)`.
# SandboxPreference: wasm
# Points: 25

# Task:
# 1. Define a function `countPaths(m: int, n: int): int` that calculates the number of unique paths.
#    - `m` is the number of rows, `n` is the number of columns.
#    - Handle edge cases like `m=0` or `n=0` (return 0 paths). If `m=1,n=1`, there's 1 path (staying put if start=end, or consider m,n as dimensions).
#      Let's assume m, n >= 1. For a 1x1 grid, there is 1 path.
#    - Create a 2D DP table (e.g., `var dp = newSeq[seq[int]](m)` and initialize inner seqs).
#    - Initialize base cases for the first row and first column to 1.
#    - Fill the rest of the table using the recurrence relation.
#    - Return `dp[m-1][n-1]`.
# 2. In `main`, call `countPaths` for a few grid sizes (e.g., 2x2, 3x3, 1x5) and print results.

# TODO: Step 1 - Define countPaths function here.
# proc countPaths(m: int, n: int): int =
#   ...

proc main() =
  # TODO: Step 2 - Call countPaths and print results.
  # echo "Paths in 2x2 grid: ", countPaths(2, 2) # Should be 2
  # echo "Paths in 3x3 grid: ", countPaths(3, 3) # Should be 6
  # echo "Paths in 1x5 grid: ", countPaths(1, 5) # Should be 1
  # echo "Paths in 3x1 grid: ", countPaths(3, 1) # Should be 1
  # echo "Paths in 1x1 grid: ", countPaths(1, 1) # Should be 1

  echo "Path counting on grid not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Paths in 2x2 grid: 2
# Paths in 3x3 grid: 6
# Paths in 1x5 grid: 1
# Paths in 3x1 grid: 1
# Paths in 1x1 grid: 1
# ```
