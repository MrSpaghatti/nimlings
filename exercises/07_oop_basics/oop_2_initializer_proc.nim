# Description: Use a procedure to initialize and return object instances.
# Hint: It's common to create a `proc newMyObject(...): MyObject = ...`
# This proc can set default values or compute initial field values.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define an object type `Player` with fields:
#    - `name: string`
#    - `score: int`
#    - `isActive: bool`
# 2. Define a procedure `newPlayer` that takes a `name: string` as a parameter.
#    - This proc should return a new `Player` instance where:
#      - `name` is set from the parameter.
#      - `score` is initialized to 0.
#      - `isActive` is initialized to `true`.
# 3. In `main`, create two players using `newPlayer`: "Alice" and "Bob".
# 4. Print the details of each player (name, score, isActive).

# TODO: Step 1 - Define the Player object type here.
# type Player = object
#   ...

# TODO: Step 2 - Define the newPlayer procedure here.
# proc newPlayer(name: string): Player =
#   ...

proc main() =
  # TODO: Step 3 - Create two players using newPlayer.
  # let player1 = newPlayer("Alice")
  # let player2 = newPlayer("Bob")

  # TODO: Step 4 - Print player details.
  # Example print for player1:
  # echo "Player: ", player1.name, ", Score: ", player1.score, ", Active: ", player1.isActive

  echo "Object initializer or usage not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Player: Alice, Score: 0, Active: true
# Player: Bob, Score: 0, Active: true
# ```
