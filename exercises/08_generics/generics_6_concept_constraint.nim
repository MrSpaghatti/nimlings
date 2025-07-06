# Description: Use `concept` to define more complex type constraints for generics.
# Hint: `import concepts`. A `concept` defines a set of requirements a type must meet.
# Example:
# type HasName* = concept x
#   x.name is string  # Requires the type to have a 'name' field of type string
#
# proc printName[T: HasName](item: T) = echo item.name
# SandboxPreference: wasm
# Points: 20

import concepts # For defining concepts

# Task:
# 1. Define a concept `Identifiable` which requires a type to have:
#    - An `id` field of type `int`.
#    - A `description` field of type `string`.
# 2. Define two object types, `Product` and `Service`, both implementing the `Identifiable` concept.
#    - `Product` should have `id: int`, `description: string`, and `price: float`.
#    - `Service` should have `id: int`, `description: string`, and `hourlyRate: float`.
# 3. Define a generic procedure `displayIdentifier[T: Identifiable](item: T)` that prints
#    the item's `id` and `description` in the format "ID: [id] - Description: [description]".
# 4. In `main`:
#    a. Create an instance of `Product`.
#    b. Create an instance of `Service`.
#    c. Call `displayIdentifier` for both instances.

# TODO: Step 1 - Define the Identifiable concept.

# TODO: Step 2a - Define Product object type.

# TODO: Step 2b - Define Service object type.

# TODO: Step 3 - Define generic proc displayIdentifier[T: Identifiable].

proc main() =
  # TODO: Step 4a - Create and display Product.
  # let prod = Product(id: 101, description: "Super Widget", price: 29.99)
  # displayIdentifier(prod)
  echo "Product display not implemented." # Placeholder

  # TODO: Step 4b - Create and display Service.
  # let serv = Service(id: 202, description: "Consulting Hour", hourlyRate: 75.0)
  # displayIdentifier(serv)
  echo "Service display not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# ID: 101 - Description: Super Widget
# ID: 202 - Description: Consulting Hour
# ```
