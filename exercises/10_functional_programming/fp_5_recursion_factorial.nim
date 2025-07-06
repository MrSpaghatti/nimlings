# Description: Learn to use recursion to solve problems by breaking them into smaller, self-similar subproblems.
# Hint: A recursive function calls itself. It must have a base case to stop the recursion.
# Factorial: n! = n * (n-1)!  Base case: 0! = 1 or 1! = 1.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a recursive function `factorial` that takes a non-negative integer `n`.
#    - If `n` is 0 or 1 (base case), it should return 1.
#    - Otherwise (recursive step), it should return `n * factorial(n - 1)`.
# 2. In `main`, calculate and print the factorial of 5.
# 3. Calculate and print the factorial of 0.
# 4. Calculate and print the factorial of 1.

# TODO: Step 1 - Define the recursive factorial function here.
# proc factorial(n: int): int =
#   ...

proc main() =
  # TODO: Step 2, 3, 4 - Call factorial and print results.
  # echo "Factorial of 5: ", factorial(5)
  # echo "Factorial of 0: ", factorial(0)
  # echo "Factorial of 1: ", factorial(1)
  echo "Factorial calculations not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Factorial of 5: 120
# Factorial of 0: 1
# Factorial of 1: 1
# ```
