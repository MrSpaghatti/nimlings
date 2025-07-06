# Description: Understand reference semantics with `ref object of RootObj` (class types).
# Hint: `ref object` types are allocated on the heap and variables hold references to them.
# Assignment copies the reference, not the object itself. Changes via one reference
# are visible via other references to the same object.
# `RootObj` is the base for types that can be used with `of` for runtime type checks, often used with `ref`.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a type `Student = ref object of RootObj` with fields:
#    - `name: string`
#    - `grade: int`
# 2. Create a procedure `newStudent(name: string, grade: int): Student` that returns a new Student instance.
# 3. In `main`:
#    a. Create a `studentA` instance for "Alice" with grade 90 using `newStudent`.
#    b. Assign `studentA` to another variable `studentB`.
#    c. Modify `studentB.grade` to 95.
#    d. Print `studentA.name` and `studentA.grade`. (Observe that studentA's grade changed).
#    e. Create `studentC` for "Carol" with grade 88.
#    f. Check if `studentA` is the same instance as `studentB` (should be true).
#    g. Check if `studentA` is the same instance as `studentC` (should be false).
#       (Hint: Reference comparison `is` can be used, but for objects, direct `==` on refs checks identity).

# TODO: Step 1 - Define Student type.

# TODO: Step 2 - Define newStudent proc.

proc main() =
  # TODO: Step 3a - Create studentA
  # var studentA = newStudent("Alice", 90)
  echo "Student A creation not implemented." # Placeholder

  # TODO: Step 3b - Assign studentA to studentB
  # var studentB = studentA
  # echo "Student B assignment not implemented." # Placeholder

  # TODO: Step 3c - Modify studentB.grade
  # studentB.grade = 95
  # echo "Student B grade modification not implemented." # Placeholder

  # TODO: Step 3d - Print studentA's details
  # echo "Student A after B's grade change: Name - ", studentA.name, ", Grade - ", studentA.grade
  echo "Student A print not implemented." # Placeholder

  # TODO: Step 3e - Create studentC
  # var studentC = newStudent("Carol", 88)
  echo "Student C creation not implemented." # Placeholder

  # TODO: Step 3f & 3g - Check instance identity
  # echo "studentA is studentB: ", (studentA == studentB) # For ref objects, == checks identity
  # echo "studentA is studentC: ", (studentA == studentC)
  echo "Identity checks not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Student A after B's grade change: Name - Alice, Grade - 95
# studentA is studentB: true
# studentA is studentC: false
# ```
