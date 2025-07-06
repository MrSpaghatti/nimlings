# Description: Learn to define methods, which are procedures associated with an object type.
# Hint: Methods are procs where the first parameter is an instance of the object.
# `proc area(rect: Rectangle): float = rect.width * rect.height`
# Can be called as `myRect.area()` or `area(myRect)`.
# SandboxPreference: wasm
# Points: 10

# Task:
# 1. Define an object type `Rectangle` with fields `width: float` and `height: float`.
# 2. Define a method `area` that takes a `Rectangle` instance and returns its area (width * height).
# 3. Define another method `perimeter` that takes a `Rectangle` instance and returns its perimeter (2 * (width + height)).
# 4. In `main`, create a `Rectangle` instance with width 5.0 and height 3.0.
# 5. Call both methods and print the rectangle's area and perimeter.

# TODO: Step 1 - Define Rectangle object type.

# TODO: Step 2 - Define area method.

# TODO: Step 3 - Define perimeter method.

proc main() =
  # TODO: Step 4 - Create a Rectangle instance.
  # let rect = Rectangle(width: 5.0, height: 3.0)

  # TODO: Step 5 - Call methods and print results.
  # echo "Rectangle Area: ", rect.area()
  # echo "Rectangle Perimeter: ", rect.perimeter()

  echo "Methods not fully implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Rectangle Area: 15.0
# Rectangle Perimeter: 16.0
# ```
