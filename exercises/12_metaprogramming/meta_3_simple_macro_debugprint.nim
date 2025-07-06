# Description: Introduction to macros for more advanced compile-time code generation.
# Hint: `import macros`. Macros receive AST (Abstract Syntax Tree) nodes as parameters.
# `macro name(params): untyped = ...body...` (often returns an AST node).
# `params` are often `typedesc` for variables/expressions, or `untyped` for more flexibility.
# `exprToStr(astNode)` converts an AST node (like a variable name) to its string representation.
# `quote do: ...` is used to construct ASTs.
# SandboxPreference: native # Macros, esp. those inspecting code structure, are better tested natively.
# Points: 25

import macros # For exprToStr, quote and other macro utilities

# Task:
# 1. Define a macro named `debugPrint` that takes one parameter `variable` of type `typedesc`.
#    This macro should generate code that prints the name of the variable (as a string)
#    followed by its value. For example, if `let x = 10`, then `debugPrint(x)` should
#    effectively do `echo "x: ", x`.
# 2. In `main`:
#    a. Define an integer variable `myInt` and assign it a value. Call `debugPrint(myInt)`.
#    b. Define a string variable `myString` and assign it a value. Call `debugPrint(myString)`.

# TODO: Step 1 - Define the 'debugPrint' macro here.
# macro debugPrint(variable: typedesc): untyped =
#   let varNameStr = exprToStr(variable) # Get variable name as string (macros.exprToStr if not disambiguated)
#   result = quote do:
#     echo varNameStr, ": ", `variable` # `variable` here refers to the AST node for the var itself

proc main() =
  # TODO: Step 2a - Use debugPrint with an integer.
  let myInt = 42
  # debugPrint(myInt)
  echo "debugPrint for myInt not implemented." # Placeholder

  # TODO: Step 2b - Use debugPrint with a string.
  let myString = "Nim macro"
  # debugPrint(myString)
  echo "debugPrint for myString not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# myInt: 42
# myString: Nim macro
# ```
