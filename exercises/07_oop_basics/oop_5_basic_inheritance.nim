# Description: Learn about inheritance, where an object type can inherit fields and methods from a base type.
# Hint: Use `type DerivedObject = object of BaseObject` to define inheritance.
# Derived objects have all fields of the base, plus their own.
# Methods defined for the base type can also be called on derived types.
# SandboxPreference: wasm
# Points: 20

# Task:
# 1. Define a base object type `GenericVehicle` with a field `speed: float`.
# 2. Define a method `describe(v: GenericVehicle): string` that returns a string like "Generic vehicle moving at [speed] km/h".
# 3. Define a derived object type `Car` that inherits from `GenericVehicle` and adds a field `numberOfDoors: int`.
# 4. Define a method `describe(c: Car): string` that overrides the base method (or is a new one, Nim handles this via dispatch)
#    to return "Car with [doors] doors, moving at [speed] km/h".
#    (For true overriding with dynamic dispatch, you'd use `method` keyword, but for this basic exercise,
#     proc overloading by type will demonstrate the concept sufficiently for different descriptions).
# 5. In `main`:
#    a. Create a `GenericVehicle` instance, set its speed, and print its description using the base `describe` method.
#    b. Create a `Car` instance, set its speed and numberOfDoors, and print its description using the `Car` specific `describe` method.

# TODO: Step 1 - Define GenericVehicle object type.

# TODO: Step 2 - Define describe method for GenericVehicle.

# TODO: Step 3 - Define Car object type inheriting from GenericVehicle.

# TODO: Step 4 - Define describe method for Car.

proc main() =
  # TODO: Step 5a - Create GenericVehicle, set speed, print description.
  # var vehicle = GenericVehicle(speed: 60.0)
  # echo vehicle.describe()
  echo "GenericVehicle part not implemented." # Placeholder

  # TODO: Step 5b - Create Car, set speed and doors, print description.
  # var myCar = Car(speed: 100.0, numberOfDoors: 4)
  # echo myCar.describe()
  echo "Car part not implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Generic vehicle moving at 60.0 km/h
# Car with 4 doors, moving at 100.0 km/h
# ```
