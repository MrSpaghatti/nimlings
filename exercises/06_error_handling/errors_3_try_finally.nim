# Description: Understand the `finally` block for cleanup code that must always execute.
# Hint: Code in a `finally` block runs whether an exception occurred in the `try` block or not.
# It's often used for releasing resources (like closing files).
# try:
#   # Code that might raise an error
# finally:
#   # Cleanup code
# SandboxPreference: wasm
# Points: 10

# Task: Simulate a resource being opened and then closed, even if an error occurs.
# 1. Print "Opening resource..."
# 2. Inside a `try` block:
#    a. Print "Resource open, performing action..."
#    b. (Optional, for testing error path) If a global const `SIMULATE_ERROR` is true, raise a new `ValueError`.
#    c. Print "Action completed." (This won't print if an error is raised before it).
# 3. Inside a `finally` block associated with the `try`:
#    a. Print "Closing resource..."

# For testing, we'll call a main proc twice, once with SIMULATE_ERROR = false, once with true.
const SIMULATE_ERROR_PATH_A = false # For the first call path
const SIMULATE_ERROR_PATH_B = true  # For the second call path

proc simulateResourceAction*(simulateError: bool) =
  echo "Opening resource..."
  try:
    echo "Resource open, performing action..."
    if simulateError:
      raise newException(ValueError, "Simulated error during action!")
    echo "Action completed." # This line might not be reached
  # TODO: Add the `finally` block here with its print statement.
  # finally:
  #   echo "Closing resource..."
  # If no finally block, the placeholder will indicate it.
  # For the purpose of this exercise, if there's no 'finally' block,
  # the structure is incomplete. We will assume the student adds it.
  # If an error is raised and not caught by an `except` (which we are not adding here),
  # the program might terminate before the "Closing resource..." if it's not in `finally`.
  # The goal is to show `finally` always runs.

  # The exercise setup expects the "Closing resource..." to be printed by the user's `finally` block.
  # If there's no `finally` block, the ExpectedOutput won't match if an error occurs.
  # To make the exercise solvable without requiring an `except` block for this specific lesson on `finally`,
  # we'll just assume the `finally` is added by the user.
  # The placeholder below is if they don't add the `finally` block AND no error occurs.
  # If an error occurs and there's no `finally`, "Closing resource..." won't print.
  # The ExpectedOutput is crafted assuming `finally` is correctly used.

  # This is a bit tricky to structure as an exercise without also teaching `except` fully.
  # The core test is: does "Closing resource..." print in both error and non-error cases?
  # The easiest way for the user is to add `finally: echo "Closing resource..."`.

  # Let's add a marker if the finally block wasn't effectively run (e.g. by user forgetting it)
  # This is hard to detect perfectly. Assume user follows instructions for `finally`.
  # The test output will verify if "Closing resource..." is printed.

  # For the placeholder, let's assume if they don't add finally, they might miss this.
  # But the prompt is to *add* the finally block.
  # So, no placeholder needed here if they follow the primary instruction.

proc main() =
  echo "--- Scenario 1: No error ---"
  simulateResourceAction(SIMULATE_ERROR_PATH_A)
  echo "\n--- Scenario 2: With error (ValueError expected if not caught) ---"
  try:
    simulateResourceAction(SIMULATE_ERROR_PATH_B)
  except ValueError as e: # We catch it here so program continues for testing output
    echo "Caught expected error: ", e.msg
    # If user's finally was correct, "Closing resource..." should have printed before this.

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# --- Scenario 1: No error ---
# Opening resource...
# Resource open, performing action...
# Action completed.
# Closing resource...
#
# --- Scenario 2: With error (ValueError expected if not caught) ---
# Opening resource...
# Resource open, performing action...
# Closing resource...
# Caught expected error: Simulated error during action!
# ```
