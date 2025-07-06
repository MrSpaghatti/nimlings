# Description: Learn to apply type constraints to generic parameters.
# Hint: Use `[T: SomeTypeConcept]` or `[T: typeA | typeB]` to restrict the types `T` can be.
# `SomeNumber` (from `import concepts` or `system` for basic numbers) matches any numeric type.
# `SomeInteger` matches integer types. `SomeFloat` matches float types.
# You can also use specific types or type classes.
# SandboxPreference: wasm
# Points: 15

import concepts # For SomeNumber, SomeInteger, SomeFloat (may also be in system for basic cases)

# Task:
# 1. Define a generic procedure `addNumerics[T: SomeNumber](a: T, b: T): T`
#    that takes two parameters of the same numeric type and returns their sum.
# 2. Define a generic procedure `printLength[T: string|seq|array](collection: T)`
#    that takes either a string, a sequence, or an array and prints its length using `len()`.
#    (Note: `string|seq|array` is a simplified constraint; a concept or type class might be more robust
#     for "has a len() proc", but this demonstrates the OR syntax for constraints).
# 3. In `main`:
#    a. Call `addNumerics` with two integers and print the result.
#    b. Call `addNumerics` with two floats and print the result.
#    c. Call `printLength` with a string.
#    d. Call `printLength` with a sequence of integers.

# TODO: Step 1 - Define generic proc addNumerics[T: SomeNumber]

# TODO: Step 2 - Define generic proc printLength[T: string|seq|array]
# For the constraint `string|seq|array`, this might be tricky without a concept.
# A simpler constraint for the exercise could be `[T: seq|string]` or just `[T:seq]` and `[T:string]` overloads.
# Let's simplify to `[T:interface دارای len: proc():int]` if possible, or use explicit types for now.
# For this exercise, let's assume the user might need to implement it for `seq[U]` and `string` separately
# if a direct union constraint on `len` isn't straightforward for beginners.
# Alternative for printLength: proc printLength[T](collection: T) where T has len: int ... (not std syntax)
#
# Let's use a concept for things that have a `len` proc for better illustration if it's not too complex.
# If concepts are too much, we can make two procs: printSeqLen[T](s: seq[T]) and printStrLen(s: string).
#
# Simpler approach for the exercise: Use a type class constraint like `[T: دارای len: proc(): int]`
# This is advanced. For now, let's use `[T: seq|string]` and see if it compiles for `len`.
# Nim's `len` is a built-in that works on seq, string, array.
# So, `[T: seq|string|array]` should work for things that `len` applies to.
# Let's stick to `string|seq|array` for the constraint, and make the output generic.

# TODO: Step 2 - Define generic proc printLength[T: string|seq|array]
# It should print "Length of collection: [length]"
# proc printLength[T: string|seq|array](collection: T) =
#   echo "Length of collection: ", len(collection)


proc main() =
  # TODO: Step 3a - Call addNumerics with integers
  # echo "Sum of 5 and 10 (ints): ", addNumerics(5, 10)
  echo "addNumerics with ints not implemented." # Placeholder

  # TODO: Step 3b - Call addNumerics with floats
  # echo "Sum of 2.5 and 3.7 (floats): ", addNumerics(2.5, 3.7)
  echo "addNumerics with floats not implemented." # Placeholder

  # TODO: Step 3c - Call printLength with a string
  let myString = "Hello Nim"
  # printLength(myString)
  echo "printLength for string not implemented." # Placeholder

  # TODO: Step 3d - Call printLength with a sequence
  let mySeq = @[1, 2, 3, 4]
  # printLength(mySeq)
  echo "printLength for sequence not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Sum of 5 and 10 (ints): 15
# Sum of 2.5 and 3.7 (floats): 6.2
# Length of collection: 9
# Length of collection: 4
# ```
