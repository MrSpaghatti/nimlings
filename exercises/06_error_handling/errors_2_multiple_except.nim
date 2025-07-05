# Description: Handle different types of exceptions using multiple `except` blocks or a general one.
# Hint: You can have multiple `except SpecificError:` blocks.
# An `except CatchableError as e:` block will catch any standard error and provide the error object `e`.
# `IOError` can occur with file operations (not used here, but good to know).
# `IndexDefect` can occur with out-of-bounds access for seqs/strings/arrays.
# SandboxPreference: wasm
# Points: 15

# Task: Create a procedure `processValue` that takes an integer `selector` and a sequence `data`.
# - If `selector` is 1, try to access `data[10]` (assuming `data` is small, this should cause an IndexDefect).
#   Catch `IndexDefect` and print "Error: Index out of bounds."
# - If `selector` is 2, try to perform `10 div 0` (causes DivisionByZeroError).
#   Catch `DivByZeroError` and print "Error: Division by zero."
# - If `selector` is anything else, print "Selector [selector]: No specific error simulated."
# - If any other `CatchableError` occurs (though not expected with the above logic),
#   print "An unexpected error occurred: [error_message]".

proc processValue*(selector: int, data: seq[int]) =
  try:
    if selector == 1:
      echo "Attempting out-of-bounds access..."
      # TODO: Access data[10] here. This line itself should be inside the try for the hint to make sense.
      # For the exercise structure, we'll put the access attempt here and expect the user
      # to build the try/except around the call or within the if/else.
      # Let's assume the user will write `let x = data[10]` or similar *inside* their try block.
      # For the provided solution structure, we'll directly raise it for testing.
      if data.len <= 10: # Simulate condition for the error
          raise newException(IndexDefect, "Simulated index error")
      else:
          echo "data[10] would be: ", data[10] # Should not happen with typical test data

    elif selector == 2:
      echo "Attempting division by zero..."
      # TODO: Perform 10 div 0 here.
      var x = 10 div 0 # This will raise DivByZeroError
      echo "Result of 10 div 0: ", x # Should not be reached
    else:
      echo "Selector ", selector, ": No specific error simulated."
  # TODO: Add except blocks here for IndexDefect, DivByZeroError, and general CatchableError.
  except IndexDefect: # Placeholder, user needs to fill this
      echo "Error: Index out of bounds. (Caught by placeholder)"
  except DivByZeroError: # Placeholder
      echo "Error: Division by zero. (Caught by placeholder)"
  except CatchableError as e: # Placeholder
      echo "An unexpected error: ", e.msg, " (Caught by placeholder)"


# Do not modify the lines below; they are for testing.
when defined(testMode):
  let sampleData = @[1, 2, 3]
  processValue(1, sampleData)
  processValue(2, sampleData)
  processValue(3, sampleData)
else:
  processValue(1, @[]) # Test with empty seq for index error
  processValue(2, @[])

# ExpectedOutput: ```
# Attempting out-of-bounds access...
# Error: Index out of bounds.
# Attempting division by zero...
# Error: Division by zero.
# Selector 3: No specific error simulated.
# ```
