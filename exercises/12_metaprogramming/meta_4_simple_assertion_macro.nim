# Description: Create a simple assertion macro that provides a custom message on failure.
# Hint: `import macros`. The macro will take a boolean condition and an optional message.
# If the condition is false, it should print the message and perhaps the condition itself.
# Use `quote do: ...` to generate an `if not (condition): ...` block.
# `lineinfo.lineinfoStr(context())` can get current line info for error messages. (More advanced)
# For simplicity, let's not use lineinfoStr in this exercise to keep it basic.
# SandboxPreference: native
# Points: 20

import macros

# Task:
# 1. Define a macro `myAssert` that takes two parameters:
#    - `condition: bool` (actually `typedesc` to capture the expression)
#    - `message: string` (a string literal)
#    If the `condition` evaluates to false at runtime, the macro should expand to code
#    that prints: "Assertion failed: [message]. Condition: [stringified condition]".
# 2. In `main`:
#    a. Use `myAssert` with a condition that is true (e.g., `1 + 1 == 2`) and a message.
#       (Nothing should be printed by this assertion).
#    b. Use `myAssert` with a condition that is false (e.g., `5 < 3`) and a message.
#       (This should print the assertion failure message).
#    c. Print a "Tests finished." message at the end of main to show execution continued.


# TODO: Step 1 - Define the 'myAssert' macro here.
# macro myAssert(condition: typedesc, message: string): untyped =
#   let condStr = exprToStr(condition)
#   result = quote do:
#     if not (`condition`):
#       echo "Assertion failed: ", `message`, ". Condition: ", `condStr`

proc main() =
  # TODO: Step 2a - Use myAssert with a true condition.
  # myAssert(1 + 1 == 2, "Math check one")
  echo "True assertion not implemented or not silent." # Placeholder

  # TODO: Step 2b - Use myAssert with a false condition.
  # myAssert(5 < 3, "Value check failed")
  echo "False assertion not implemented." # Placeholder

  echo "Tests finished."


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Assertion failed: Value check failed. Condition: (5 < 3)
# Tests finished.
# ```
