# Description: Compare value semantics of `object` with reference semantics of `ref object`.
# Hint: Plain `object` types are value types. Assignment copies the entire object.
# `ref object` types are reference types. Assignment copies the reference.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define a value type `ValuePoint = object; x, y: int`.
# 2. Define a reference type `RefPoint = ref object of RootObj; x, y: int`.
# 3. In `main`:
#    a. Create `vp1 = ValuePoint(x:1, y:1)`. Assign `vp2 = vp1`. Modify `vp2.x = 100`.
#       Print `vp1.x` (should be unchanged).
#    b. Create `rp1 = RefPoint(x:1, y:1)`. Assign `rp2 = rp1`. Modify `rp2.x = 100`.
#       Print `rp1.x` (should be changed).

# TODO: Step 1 - Define ValuePoint.

# TODO: Step 2 - Define RefPoint.

proc main() =
  echo "--- Value Semantics (object) ---"
  # TODO: Step 3a - ValuePoint demonstration
  # var vp1 = ValuePoint(x:1, y:1)
  # var vp2 = vp1
  # vp2.x = 100
  # echo "vp1.x after modifying vp2.x: ", vp1.x
  echo "ValuePoint demo not implemented." # Placeholder

  echo "\n--- Reference Semantics (ref object) ---"
  # TODO: Step 3b - RefPoint demonstration
  # var rp1 = RefPoint(x:1, y:1)
  # var rp2 = rp1
  # rp2.x = 100
  # echo "rp1.x after modifying rp2.x: ", rp1.x
  echo "RefPoint demo not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# --- Value Semantics (object) ---
# vp1.x after modifying vp2.x: 1
#
# --- Reference Semantics (ref object) ---
# rp1.x after modifying rp2.x: 100
# ```
