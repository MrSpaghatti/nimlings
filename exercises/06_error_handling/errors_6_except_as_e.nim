# Description: Learn to catch exceptions and access the exception object using `except ErrorType as e:`.
# Hint: The `as e` part binds the caught exception instance to the variable `e`.
# You can then access its fields, like `e.msg` for the error message.
# If you have custom exceptions with more fields, you can access those too.
# SandboxPreference: wasm
# Points: 10

# Task:
# 1. (Re-use or re-define) a custom exception `MyCustomError = object of CatchableError`
#    that has an additional field `errorCode: int`.
# 2. Create a procedure `performRiskyOperation(code: int)` that:
#    - If `code` is negative, `raise`s a `MyCustomError` with a message like "Invalid code provided"
#      and sets the `errorCode` field to the given `code`.
#    - Otherwise, prints "Operation successful with code [code]".
# 3. In `main`, call `performRiskyOperation` twice in `try` blocks:
#    a. Once with a positive code (e.g., 100).
#    b. Once with a negative code (e.g., -5) and catch `MyCustomError as e`.
#       Inside the `except` block, print both `e.msg` and `e.errorCode`.

# TODO: Step 1 - Define MyCustomError with an errorCode field.
# type MyCustomError* = object of CatchableError
#   errorCode*: int

# TODO: Step 2 - Define performRiskyOperation procedure.
# proc performRiskyOperation(code: int) =
#   if code < 0:
#     raise newException(MyCustomError, "Invalid code provided", errorCode = code)
#   else:
#     echo "Operation successful with code ", code

proc main() =
  echo "--- Scenario: Successful Operation ---"
  # TODO: Call performRiskyOperation with a positive code.
  # try:
  #   performRiskyOperation(100)
  # except MyCustomError as e: # Should not be caught here
  #   echo "Unexpected error: ", e.msg, " (Code: ", e.errorCode, ")"
  echo "Success scenario not implemented." # Placeholder

  echo "\n--- Scenario: Risky Operation Fails ---"
  # TODO: Call performRiskyOperation with a negative code and catch MyCustomError as e.
  # try:
  #   performRiskyOperation(-5)
  # except MyCustomError as e:
  #   echo "Caught MyCustomError!"
  #   echo "  Message: ", e.msg
  #   echo "  Error Code: ", e.errorCode
  echo "Failure scenario not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# --- Scenario: Successful Operation ---
# Operation successful with code 100
#
# --- Scenario: Risky Operation Fails ---
# Caught MyCustomError!
#   Message: Invalid code provided
#   Error Code: -5
# ```
