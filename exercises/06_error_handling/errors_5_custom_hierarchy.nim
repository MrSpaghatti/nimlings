# Description: Define a hierarchy of custom exceptions to categorize errors more specifically.
# Hint: Define a base custom error `type MyBaseError = object of CatchableError`.
# Then define more specific errors inheriting from your base: `type MySpecificError = object of MyBaseError`.
# `except MyBaseError` will catch instances of `MyBaseError` AND its derived types like `MySpecificError`.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a base custom exception `AppError = object of CatchableError`.
# 2. Define two specific exceptions inheriting from `AppError`:
#    - `ConfigError = object of AppError` (for configuration issues).
#    - `NetworkError = object of AppError` (for simulated network issues).
# 3. Create a procedure `initializeApp(configStatus: string, networkStatus: string)` that:
#    - If `configStatus` is "missing", raises a `ConfigError` with message "Configuration file not found."
#    - If `networkStatus` is "down", raises a `NetworkError` with message "Network connection failed."
#    - Otherwise, prints "Application initialized successfully."
# 4. In `main`, call `initializeApp` multiple times within `try` blocks to demonstrate catching:
#    a. Specifically `ConfigError`.
#    b. Specifically `NetworkError`.
#    c. Generally `AppError` (which should catch either if not caught more specifically).
#    d. A successful initialization.

# TODO: Step 1 - Define AppError.

# TODO: Step 2 - Define ConfigError and NetworkError.

# TODO: Step 3 - Define initializeApp procedure.

proc main() =
  echo "--- Scenario: Config Error ---"
  # TODO: Call initializeApp to trigger ConfigError and catch it as ConfigError.
  # try:
  #   initializeApp("missing", "up")
  # except ConfigError as e:
  #   echo "Caught ConfigError: ", e.msg
  # except AppError as e: # Fallback if specific catch is missed by user
  #   echo "Caught general AppError for config issue: ", e.msg
  echo "ConfigError scenario not implemented." # Placeholder

  echo "\n--- Scenario: Network Error ---"
  # TODO: Call initializeApp to trigger NetworkError and catch it as NetworkError.
  # try:
  #   initializeApp("ok", "down")
  # except NetworkError as e:
  #   echo "Caught NetworkError: ", e.msg
  # except AppError as e:
  #   echo "Caught general AppError for network issue: ", e.msg
  echo "NetworkError scenario not implemented." # Placeholder

  echo "\n--- Scenario: Catching with base AppError ---"
  # TODO: Call initializeApp to trigger ConfigError but catch it as AppError.
  # try:
  #   initializeApp("missing", "up") # Trigger ConfigError
  # except AppError as e:
  #   echo "Caught base AppError (was ConfigError): ", e.msg
  echo "Base AppError catch scenario not implemented." # Placeholder

  echo "\n--- Scenario: Successful Initialization ---"
  # TODO: Call initializeApp for successful path.
  # try:
  #   initializeApp("ok", "up")
  # except AppError as e: # Should not happen
  #   echo "Unexpected AppError: ", e.msg
  echo "Success scenario not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# --- Scenario: Config Error ---
# Caught ConfigError: Configuration file not found.
#
# --- Scenario: Network Error ---
# Caught NetworkError: Network connection failed.
#
# --- Scenario: Catching with base AppError ---
# Caught base AppError (was ConfigError): Configuration file not found.
#
# --- Scenario: Successful Initialization ---
# Application initialized successfully.
# ```
