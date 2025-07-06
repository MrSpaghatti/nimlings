# Description: Learn to define and use converters between different object types.
# Hint: A `converter` is a special proc that allows implicit or explicit type conversions.
# Define like: `converter toTypeName(fromInstance: FromType): ToType = ...`
# It can then be used like: `let newTypeInstance = toTypeName(oldTypeInstance)` or sometimes implicitly.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define an object type `Point2D` with fields `x, y: float`.
# 2. Define an object type `Point3D` with fields `x, y, z: float`.
# 3. Define a `converter toPoint3D(p2d: Point2D): Point3D`.
#    This converter should take a `Point2D` and return a `Point3D`
#    where the `x` and `y` fields are copied from the `Point2D`, and `z` is set to `0.0`.
# 4. In `main`:
#    a. Create an instance of `Point2D` (e.g., x=3.0, y=4.0).
#    b. Convert this `Point2D` instance to a `Point3D` instance using your converter.
#    c. Print the x, y, and z fields of the resulting `Point3D` instance.

# TODO: Step 1 - Define Point2D object type.

# TODO: Step 2 - Define Point3D object type.

# TODO: Step 3 - Define the converter toPoint3D.

proc main() =
  # TODO: Step 4a - Create a Point2D instance.
  # let p2 = Point2D(x: 3.0, y: 4.0)
  # echo "Original 2D Point: (", p2.x, ", ", p2.y, ")"
  echo "Point2D creation not implemented." # Placeholder

  # TODO: Step 4b - Convert to Point3D.
  # let p3 = toPoint3D(p2) # Explicit call
  # Or, if context allows and it's unambiguous: let p3: Point3D = p2
  echo "Conversion to Point3D not implemented." # Placeholder

  # TODO: Step 4c - Print Point3D fields.
  # echo "Converted 3D Point: (", p3.x, ", ", p3.y, ", ", p3.z, ")"
  echo "Point3D printing not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Converted 3D Point: (3.0, 4.0, 0.0)
# ```
