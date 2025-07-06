# Description: Explore closures: functions that capture their lexical environment.
# Hint: A function can return another (anonymous or named) procedure. This inner procedure
# "closes over" variables from its containing scope, even after the outer function has returned.
# SandboxPreference: wasm
# Points: 20

# Task:
# 1. Define a function `makeAdder` that takes an integer `amountToAdd: int`.
#    `makeAdder` should return a new procedure. This returned procedure should:
#      - Take one integer parameter `x: int`.
#      - Return `x + amountToAdd` (where `amountToAdd` is captured from `makeAdder`'s scope).
# 2. In `main`:
#    a. Create an `add5` procedure by calling `makeAdder(5)`.
#    b. Create an `add10` procedure by calling `makeAdder(10)`.
#    c. Call `add5` with an argument (e.g., 3) and print the result.
#    d. Call `add10` with the same argument (e.g., 3) and print the result.

# TODO: Step 1 - Define makeAdder here.
# proc makeAdder(amountToAdd: int): proc(x: int): int =
#   return proc(x: int): int =
#     return x + amountToAdd

proc main() =
  # TODO: Step 2a - Create add5
  # let add5 = makeAdder(5)
  # echo "add5 proc not created." # Placeholder if not done

  # TODO: Step 2b - Create add10
  # let add10 = makeAdder(10)
  # echo "add10 proc not created." # Placeholder if not done

  let valueToTest = 3

  # TODO: Step 2c - Call add5 and print
  # echo valueToTest, " + 5 = ", add5(valueToTest)
  echo "Call to add5 not implemented." # Placeholder

  # TODO: Step 2d - Call add10 and print
  # echo valueToTest, " + 10 = ", add10(valueToTest)
  echo "Call to add10 not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# 3 + 5 = 8
# 3 + 10 = 13
# ```
