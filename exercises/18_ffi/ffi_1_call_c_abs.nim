# Description: Learn basic Foreign Function Interface (FFI) to call C functions from Nim.
# Hint: Use the `{.importc: "<c_function_name>", header: "<c_header.h>", dynlib: "<library_name>" .}` pragma.
# For common libc functions, you often only need `importc` and potentially `header` if types are complex.
# The `dynlib` pragma is for dynamically linking at runtime; for standard C library functions,
# the Nim compiler usually handles linking automatically.
# We will call the `abs` function from the C standard library (often in `stdlib.h`).
# SandboxPreference: native # FFI is inherently a native operation.
# Points: 25

# Task:
# 1. Import the C standard library `abs` function, which takes an `int` and returns an `int`.
#    Its C signature is typically `int abs(int n);`.
# 2. In `main`:
#    a. Call the imported C `abs` function with -5 and print the result.
#    b. Call it with 10 and print the result.
#    c. Call it with 0 and print the result.

# TODO: Step 1 - Import the C `abs` function.
# proc c_abs(input: cint): cint {.importc: "abs", header: "<stdlib.h>".}
# Note: Using `cint` for C's `int` type is good practice for FFI.
# The header pragma helps c2nim and can inform the Nim compiler.
# For such a common function, sometimes just `importc: "abs"` might work if the compiler finds it.

proc main() =
  let val1 = -5
  let val2 = 10
  let val3 = 0

  # TODO: Step 2a - Call C abs with val1.
  # let abs1 = c_abs(val1.cint) # Convert Nim int to cint
  # echo "C abs(", val1, ") = ", abs1
  echo "C abs for val1 not implemented." # Placeholder

  # TODO: Step 2b - Call C abs with val2.
  # let abs2 = c_abs(val2.cint)
  # echo "C abs(", val2, ") = ", abs2
  echo "C abs for val2 not implemented." # Placeholder

  # TODO: Step 2c - Call C abs with val3.
  # let abs3 = c_abs(val3.cint)
  # echo "C abs(", val3, ") = ", abs3
  echo "C abs for val3 not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# C abs(-5) = 5
# C abs(10) = 10
# C abs(0) = 0
# ```
