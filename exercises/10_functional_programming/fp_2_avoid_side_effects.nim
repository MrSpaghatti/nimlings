# Description: Practice refactoring code to eliminate side effects and make functions pure.
# Hint: Instead of modifying global state or printing directly from a calculation function,
# have the function return the computed result. Let the caller handle printing or state updates.
# SandboxPreference: wasm
# Points: 15

var globalMessage = "Initial global message" # A global variable (side effect source)

# Problematic procedure with side effects:
# It modifies a global variable and prints directly.
proc processDataImpure(value: int) =
  globalMessage = "Global message changed by proc for value: " & $value
  echo "Impure proc directly prints: Result is ", value * 2

# Task:
# 1. Define a PURE function `calculateProcessedValue` that takes an `inputValue: int`.
#    It should return the result of `inputValue * 2`. It must not modify `globalMessage` or print anything.
# 2. Define a PURE function `generateStatusMessage` that takes an `inputValue: int`.
#    It should return a string like "Status for value [inputValue]: Processed.".
#    It must not modify `globalMessage` or print anything.
# 3. In `main`:
#    a. Call `calculateProcessedValue` with an input (e.g., 10). Store the result.
#    b. Call `generateStatusMessage` with the same input. Store the result.
#    c. Print the result from `calculateProcessedValue`.
#    d. Print the status message from `generateStatusMessage`.
#    e. Print the `globalMessage` to show it remains unchanged by your pure functions.

# TODO: Step 1 - Define pure function calculateProcessedValue

# TODO: Step 2 - Define pure function generateStatusMessage

proc main() =
  let testValue = 10
  echo "Initial globalMessage: ", globalMessage
  echo "---"

  # Call the original impure function to see its effects (for comparison before refactor)
  # processDataImpure(testValue) # Comment this out after implementing pure versions
  # echo "globalMessage after impure call: ", globalMessage # Shows modification
  # echo "---"

  # Reset globalMessage for the pure function test part
  globalMessage = "Initial global message (reset)"

  # TODO: Step 3a, 3b - Call your pure functions
  # let processedResult = calculateProcessedValue(testValue)
  # let statusMsg = generateStatusMessage(testValue)
  let processedResult = 0 # Placeholder
  let statusMsg = ""    # Placeholder

  # TODO: Step 3c, 3d, 3e - Print results and unchanged globalMessage
  # echo "Pure function calculated result: ", processedResult
  # echo "Pure function status message: ", statusMsg
  # echo "globalMessage after pure calls: ", globalMessage

  echo "Pure function refactoring not fully implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Initial globalMessage: Initial global message
# ---
# Pure function calculated result: 20
# Pure function status message: Status for value 10: Processed.
# globalMessage after pure calls: Initial global message (reset)
# ```
