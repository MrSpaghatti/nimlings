# Description: Use templates to generate blocks of code or statements.
# Hint: The `body` of a template can contain multiple statements.
# `untyped` parameters can also match code blocks passed to the template.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a template named `executeWithLogging` that takes two parameters:
#    - `operationName: string` (a string literal describing the operation)
#    - `codeBlock: untyped` (the block of code to execute)
#    The template should:
#    - Print "LOG: Starting [operationName]..."
#    - Execute the `codeBlock`.
#    - Print "LOG: Finished [operationName]."
# 2. In `main`, use `executeWithLogging` twice:
#    a. First time with operationName "Addition" and a code block that calculates and prints `10 + 5`.
#    b. Second time with operationName "String Concat" and a code block that defines two strings
#       and prints their concatenation.

# TODO: Step 1 - Define the 'executeWithLogging' template here.
# template executeWithLogging(operationName: string, codeBlock: untyped): untyped =
#   echo "LOG: Starting ", operationName, "..."
#   codeBlock
#   echo "LOG: Finished ", operationName, "."

proc main() =
  # TODO: Step 2a - Use executeWithLogging for Addition.
  # executeWithLogging("Addition"):
  #   let sum = 10 + 5
  #   echo "Sum result: ", sum
  echo "executeWithLogging for Addition not implemented." # Placeholder

  echo "---" # Separator for clarity

  # TODO: Step 2b - Use executeWithLogging for String Concat.
  # executeWithLogging("String Concat"):
  #   let s1 = "Hello, "
  #   let s2 = "Nim!"
  #   echo "Concatenated: ", s1 & s2
  echo "executeWithLogging for String Concat not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# LOG: Starting Addition...
# Sum result: 15
# LOG: Finished Addition.
# ---
# LOG: Starting String Concat...
# Concatenated: Hello, Nim!
# LOG: Finished String Concat.
# ```
