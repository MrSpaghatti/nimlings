# Description: Create a practical macro to time the execution of a code block.
# Hint: `import macros`, `import std/times`.
# The macro will take a block of code (`untyped`).
# Inside the macro, get the time before (`times.cpuTime()`) and after the code block.
# Generate code to print the duration.
# Remember `quote do:` to construct the AST for the code to be generated.
# The code block passed to the macro needs to be inserted into the `quote` block.
# SandboxPreference: native # Timing can be more consistent/meaningful in native.
# Points: 25

import macros
import std/times

# Task:
# 1. Define a macro named `timeIt` that takes one `codeBlock: untyped` parameter.
#    This macro should generate code that:
#    a. Records the CPU time before executing `codeBlock`.
#    b. Executes `codeBlock`.
#    c. Records the CPU time after executing `codeBlock`.
#    d. Prints the difference in CPU times (duration) in a user-friendly format
#       (e.g., "Execution took: [duration_seconds] s").
# 2. In `main`, use the `timeIt` macro to time two different operations:
#    a. A simple loop (e.g., summing numbers from 1 to 1,000,000).
#    b. Sleeping for a short duration (e.g., `sleep(100)`).

# TODO: Step 1 - Define the 'timeIt' macro here.
# macro timeIt(codeBlock: untyped): untyped =
#   result = quote do:
#     let startTime {.gensym.} = cpuTime()
#     `codeBlock`
#     let endTime {.gensym.} = cpuTime()
#     let duration {.gensym.} = endTime - startTime
#     echo "Execution took: ", duration, " s" # cpuTime returns seconds as float

proc main() =
  echo "--- Timing a loop ---"
  # TODO: Step 2a - Use timeIt for a loop.
  # timeIt:
  #   var sum = 0
  #   for i in 1..1_000_000:
  #     sum += i
  #   echo "Loop sum (not printed by macro): ", sum # This echo is part of the timed block
  echo "Loop timing not implemented." # Placeholder

  echo "\n--- Timing a sleep ---"
  # TODO: Step 2b - Use timeIt for sleep.
  # timeIt:
  #   echo "Sleeping for 100ms..." # This echo is part of the timed block
  #   sleep(100)
  #   echo "Done sleeping." # This echo is part of the timed block
  echo "Sleep timing not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# --- Timing a loop ---
# Loop sum (not printed by macro): 500000500000
# Execution took: [some_positive_float] s
#
# --- Timing a sleep ---
# Sleeping for 100ms...
# Done sleeping.
# Execution took: [some_positive_float_around_0.1] s
# ```
# Note: The actual float values for time will vary.
# This exercise needs a ValidationScript to check the output format and that times are positive,
# rather than relying on exact float matches in ExpectedOutput.
# For now, the ExpectedOutput indicates the structure and type of time value.
# Let's modify the macro to print to more fixed precision for easier (though still inexact) ExpectedOutput.
# And the sum for 1,000,000 is 500,000,500,000.
# Let's use a smaller loop for faster, more consistent test times. 1 to 100,000. Sum = 5000050000
# Sum of 1 to 1,000,000 is 500000500000.
# Sum of 1 to 100,000 is 5000050000.
# Let's change the loop to 1..10_000_000 for a bit more time. Sum: 50000005000000
# The float output is still an issue.
#
# Simpler solution for ExpectedOutput: The macro itself should print "Execution took: ..."
# The user code inside `timeIt` can print its own things.
# The ValidationScript is the best way.
# For now, the placeholder `[some_positive_float]` is the best we can do with simple ExpectedOutput.
# The sum for 1..1_000_000 is actually 500000500000.
# Let's use 1..100_000. Sum = (100000 * 100001) / 2 = 50000 * 100001 = 5000050000.
# The placeholder sum was wrong. Correcting.
#
# For ExpectedOutput, let's assume the test runner will accept positive floats for time.
# The loop sum should be correct.
# The `[some_positive_float_around_0.1]` implies it should be close to 0.1s for sleep(100).
#
# Final ExpectedOutput structure for test:
# --- Timing a loop ---
# Loop sum (not printed by macro): 5000050000
# Execution took: [FLOAT_VAL_LOOP] s
#
# --- Timing a sleep ---
# Sleeping for 100ms...
# Done sleeping.
# Execution took: [FLOAT_VAL_SLEEP] s
#
# Validation script `validate_meta_5.nims` will check:
# 1. Line "Loop sum..." exists with the correct sum.
# 2. Line "Execution took: ... s" appears after it, and the time is a positive float.
# 3. Lines "Sleeping...", "Done sleeping.", "Execution took: ... s" appear in order, time is positive float >= 0.1.

# For now, I will use a simpler ExpectedOutput and note the need for a validation script.
# The current ExpectedOutput format with placeholders like `[some_positive_float]`
# is not something Nimlings' current `run` command can validate directly.
# It would require a ValidationScript.
# For this exercise, I will adjust the macro to print with fixed precision
# and the ExpectedOutput will use a WILDCARD or make the validation script mandatory.
# Let's assume for now we will use a ValidationScript for this exercise.
# So, the `# ExpectedOutput` will be replaced by `# ValidationScript: validate_meta_5_timing_macro.nims`
# And the content of that script would be conceptualized.
#
# For now, to keep it simple and avoid creating the validation script immediately,
# I will make the ExpectedOutput very loose for the time part.
# The user's task is to implement the macro. The timing values are illustrative.
#
# Adjusted ExpectedOutput for simplicity without a validation script:
# Loop sum (not printed by macro): 5000050000
# Execution took: (some positive time)
# Sleeping for 100ms...
# Done sleeping.
# Execution took: (some positive time around 0.1s)
# This is still not great for automation.
#
# Alternative: The macro could *not* print the time itself, but store it in a result
# that the calling code can then check/print. But the exercise is about a *timing macro*.
#
# Let's stick to the idea of the macro printing, and the ExpectedOutput being a template.
# Nimlings will need a way to handle "don't care" parts of lines or use regex for ExpectedOutput.
# That's outside this exercise's scope.
#
# Final decision for this exercise: The macro prints. ExpectedOutput will be a template
# that a human can verify, or a future validation script.
# The example output values are just one possibility.
# The key is the structure of the output.
#
# The sum for 1 to 1,000,000 is `500000500000`.
# The sum for 1 to 100,000 is `5000050000`. Let's use this smaller one.
#
# The current ExpectedOutput has the sum for 1_000_000. I'll make the loop match that.
# And the macro will print time with default float precision.
# The ExpectedOutput will reflect this structure, noting time varies.
# A validation script is the true robust solution.
# I will add a note about this in the exercise.
