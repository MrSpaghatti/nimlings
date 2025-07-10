# Description: Learn to call a C function that takes a pointer to a struct and modifies its members.
# Hint: Define a Nim object type compatible with the C struct. Embed the C code (struct definition and function) using an `{.emit.}` block. Import the C function using `importc` and `nodecl` (since the definition is emitted). Pass the address of your Nim object instance to the C function using `addr()`.
# Points: 30
# SandboxPreference: native
# ExpectedOutput: ```
# Initial point: (x: 10, y: 20)
# Calling C function to translate by (dx: 5, dy: -3)...
# Modified point: (x: 15, y: 17)
# ---
# Initial point: (x: -5, y: 8)
# Calling C function to translate by (dx: -2, dy: 2)...
# Modified point: (x: -7, y: 10)
# ```

# TODO: Step 1 - Add the C code block using an emit pragma.
# This block should contain:
# 1. The C struct definition for `Point2D_C` (e.g., with int x and int y).
# 2. The C function `translatePoint` that takes `Point2D_C* point`, `int dx`, `int dy`,
#    and modifies `point->x` and `point->y`.
# Example:
# {.emit: """
# typedef struct {
#     int x;
#     int y;
# } Point2D_C;
#
# void translatePoint(Point2D_C* point, int dx, int dy) {
#     if (point != NULL) {
#         point->x += dx;
#         point->y += dy;
#     }
# }
# """.}


# TODO: Step 2 - Define the Nim object type `Point` that is memory-compatible with `Point2D_C`.
# Remember to use `cint` for fields that correspond to C `int`. Export the fields.
# type Point = object
#   x*: cint
#   y*: cint


# TODO: Step 3 - Import the C function `translatePoint` into Nim.
# Name the Nim proc something like `c_translatePoint`.
# It should take `ptr Point` as its first parameter.
# Use `importc: "translatePoint"` and `nodecl`.
# proc c_translatePoint(p: ptr Point; dx: cint; dy: cint) {.importc: "translatePoint", nodecl.}


proc main() =
  # TODO: Step 4a - Create an instance of your Point type, initialize it (e.g., x=10, y=20).
  # var myPoint1 = Point(x: 10, y: 20) # Or however you define it
  echo "Point instance 1 not implemented." # Placeholder

  # TODO: Step 4b - Print its initial state.
  # echo "Initial point: (x: ", myPoint1.x, ", y: ", myPoint1.y, ")"
  echo "Initial print 1 not implemented." # Placeholder

  # TODO: Step 4c - Call the imported C function to modify your Point instance.
  # let dx1 = 5
  # let dy1 = -3
  # echo "Calling C function to translate by (dx: ", dx1, ", dy: ", dy1, ")..."
  # c_translatePoint(addr myPoint1, dx1, dy1)
  echo "C call 1 not implemented." # Placeholder

  # TODO: Step 4d - Print its modified state.
  # echo "Modified point: (x: ", myPoint1.x, ", y: ", myPoint1.y, ")"
  echo "Modified print 1 not implemented." # Placeholder

  echo "---"

  # TODO: Step 5 - Test with another Point instance and different translation values.
  # var myPoint2 = Point(x: -5, y: 8)
  # echo "Initial point: (x: ", myPoint2.x, ", y: ", myPoint2.y, ")"
  # let dx2 = -2
  # let dy2 = 2
  # echo "Calling C function to translate by (dx: ", dx2, ", dy: ", dy2, ")..."
  # c_translatePoint(addr myPoint2, dx2, dy2)
  # echo "Modified point: (x: ", myPoint2.x, ", y: ", myPoint2.y, ")"
  echo "Second test case not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  # The C code and Nim types/procs should be defined above by the user.
  # This block will only compile and run correctly if the user has completed the TODOs.
  main()
else:
  main()
