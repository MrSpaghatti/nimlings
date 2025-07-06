# Description: Learn to define procedures that accept parameters.
# Hint: Parameters are variables declared in the procedure signature.
# `proc greet(name: string) = echo "Hello, ", name`
# Call it like `greet("Nimrod")`.
# SandboxPreference: wasm
# Points: 10

# Task: Define a procedure named `addAndPrint` that takes two integer parameters,
# `a` and `b`. The procedure should print their sum in the format "Sum: [result]".
# Then, call this procedure with a few different pairs of numbers.

# TODO: Define your `addAndPrint` procedure here.

# TODO: Call your `addAndPrint` procedure multiple times with different arguments
# to produce the ExpectedOutput below. For example:
# addAndPrint(5, 3)  # Expected: Sum: 8
# addAndPrint(12, -4) # Expected: Sum: 8
# addAndPrint(50, 50) # Expected: Sum: 100
echo "Procedure definition or calls not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
# The ExpectedOutput reflects the required calls.
when defined(testMode):
  discard # Test relies on user completing the TODOs to produce the output.
else:
  discard

# ExpectedOutput: ```
# Sum: 8
# Sum: 8
# Sum: 100
# ```
