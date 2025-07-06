# Description: Understand dynamic method dispatch using the `method` keyword.
# Hint: When you define a `proc` with the `method` keyword for a base type,
# derived types can override it. Calls to this method on a variable of the
# base type will dynamically dispatch to the correct implementation based on
# the object's actual runtime type.
# SandboxPreference: wasm
# Points: 20

# Task:
# 1. Define a base object type `Figure` with no specific fields for this example,
#    but it must be a `ref object` or an `object of RootObj` for methods to be dynamically dispatched.
#    Let's use `ref object` for clarity with polymorphism.
# 2. Define a `method draw(f: Figure): string` for the base `Figure` type.
#    This base method should return "Drawing a generic figure."
# 3. Define two derived object types, `Circle` and `Square`, inheriting from `Figure`.
#    `Circle` can have a `radius: float` (optional for this exercise, not strictly needed for draw).
#    `Square` can have a `side: float` (optional for this exercise).
# 4. Override the `draw` method for `Circle` to return "Drawing a circle."
# 5. Override the `draw` method for `Square` to return "Drawing a square."
# 6. In `main`:
#    a. Create a sequence `figures` of type `seq[Figure]`.
#    b. Add instances of `newCircle()` and `newSquare()` to this sequence.
#       (You'll need to ensure they are created as `Figure` refs, e.g. `let c: Figure = newCircle()`).
#    c. Iterate through the `figures` sequence and call the `draw` method on each element, printing the returned string.

# TODO: Step 1 - Define Figure object type (as ref object).
# type Figure* = ref object of RootObj # Or just `ref object`

# TODO: Step 2 - Define base `draw` method for Figure.
# method draw*(f: Figure): string =
#   return "Drawing a generic figure."

# TODO: Step 3 - Define Circle and Square inheriting from Figure.
# type Circle* = ref object of Figure
#   radius: float # Optional field
# type Square* = ref object of Figure
#   side: float   # Optional field

# TODO: Step 4 - Override `draw` method for Circle.
# method draw*(c: Circle): string =
#   return "Drawing a circle."

# TODO: Step 5 - Override `draw` method for Square.
# method draw*(s: Square): string =
#   return "Drawing a square."

proc main() =
  # TODO: Step 6a - Create sequence `figures`.
  # var figures: seq[Figure] = @[]

  # TODO: Step 6b - Add Circle and Square instances.
  # (Ensure they are upcast to Figure when adding or assign to Figure typed var first)
  # let myCircle: Figure = Circle(radius: 5.0) # Example if fields are present
  # let mySquare: Figure = Square(side: 4.0)   # Example if fields are present
  # figures.add(myCircle)
  # figures.add(mySquare)
  # figures.add(Figure()) # Add a base figure instance too

  # TODO: Step 6c - Iterate and call `draw`, print results.
  # for fig in figures:
  #   echo fig.draw()

  echo "Method dispatch not fully implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Drawing a circle.
# Drawing a square.
# Drawing a generic figure.
# ```
