# Description: Learn to define and use templates for code substitution at compile time.
# Hint: Templates are like powerful, hygienic macros. Define with `template name(params): untyped = ...body...`.
# The body is substituted at the call site. `untyped` means parameters are not type-checked before substitution.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a template named `square` that takes one parameter `x`.
#    This template should expand to the expression `x * x`.
# 2. In `main`:
#    a. Use the `square` template with an integer literal (e.g., 5) and print the result.
#    b. Use the `square` template with a float literal (e.g., 2.5) and print the result.
#    c. Define an integer variable `numVar` with value 3. Use `square` with `numVar` and print.
#    d. Try `square(numVar + 1)` and print the result to see how expressions are handled.

# TODO: Step 1 - Define the 'square' template here.
# template square(x: untyped): untyped =
#   x * x

proc main() =
  # TODO: Step 2a - Use square with an integer literal.
  # echo "Square of 5: ", square(5)
  echo "Square of 5 not implemented." # Placeholder

  # TODO: Step 2b - Use square with a float literal.
  # echo "Square of 2.5: ", square(2.5)
  echo "Square of 2.5 not implemented." # Placeholder

  # TODO: Step 2c - Use square with an integer variable.
  let numVar = 3
  # echo "Square of numVar (3): ", square(numVar)
  echo "Square of numVar not implemented." # Placeholder

  # TODO: Step 2d - Use square with an expression.
  # echo "Square of (numVar + 1): ", square(numVar + 1)
  echo "Square of expression not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Square of 5: 25
# Square of 2.5: 6.25
# Square of numVar (3): 9
# Square of (numVar + 1): 16
# ```
