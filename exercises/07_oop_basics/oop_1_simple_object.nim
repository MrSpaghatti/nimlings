# Description: Learn to define custom data types using `object`.
# Hint: An `object` is a collection of named fields (variables).
# Define it like:
# type MyObject = object
#   field1: string
#   field2: int
# Create an instance: `var instance = MyObject(field1: "value", field2: 123)`
# Access fields: `instance.field1`
# SandboxPreference: wasm
# Points: 10

# Task:
# 1. Define an object type named `Book` with two fields:
#    - `title` of type `string`
#    - `author` of type `string`
# 2. Create an instance of `Book` for "The Hitchhiker's Guide to the Galaxy" by "Douglas Adams".
# 3. Print the title of the book.
# 4. Print the author of the book.

# TODO: Step 1 - Define the Book object type here.
# type Book = object
#   ...
#   ...

proc main() =
  # TODO: Step 2 - Create an instance of your Book object.
  # var myBook = Book(...)

  # TODO: Step 3 - Print the book's title.
  # echo "Title: ", myBook.title

  # TODO: Step 4 - Print the book's author.
  # echo "Author: ", myBook.author

  echo "Object definition or usage not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Title: The Hitchhiker's Guide to the Galaxy
# Author: Douglas Adams
# ```
