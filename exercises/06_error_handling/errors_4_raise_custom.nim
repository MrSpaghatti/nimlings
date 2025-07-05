# Description: Learn to define and `raise` custom exceptions for specific error conditions.
# Hint: Define a custom exception by `type MyError* = object of CatchableError`.
# Use `raise newException(MyError, "Error message")` to throw it.
# Catch it with `except MyError as e:`.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a custom exception type named `InvalidAgeError` that inherits from `CatchableError`.
# 2. Create a procedure `registerUser` that takes `name: string` and `age: int`.
#    - If `age` is less than 18, it should `raise` an `InvalidAgeError` with a message like "Age must be 18 or older."
#    - Otherwise, it should print "User [name] registered with age [age]."
# 3. In a `main` procedure, call `registerUser` twice in `try` blocks:
#    - Once with valid age (e.g., 25).
#    - Once with an invalid age (e.g., 16) and catch the `InvalidAgeError`, printing its message.

# TODO: Step 1 - Define InvalidAgeError here.
# type InvalidAgeError* = object of CatchableError

# TODO: Step 2 - Define registerUser procedure here.
# proc registerUser(name: string, age: int) = ...

proc main() =
  # TODO: Step 3 - Call registerUser and handle potential InvalidAgeError.
  echo "Custom exception handling not fully implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  # Example of how you might test manually
  # try:
  #   registerUser("Test User", 10) # This should raise and be caught by your try/except in main
  # except InvalidAgeError as e:
  #   echo "Caught in manual test: ", e.msg
  main()


# ExpectedOutput: ```
# User Alice registered with age 25.
# Error registering Bob: Age must be 18 or older.
# ```
