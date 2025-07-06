# Contributing New Exercises to Nimlings

Thank you for your interest in contributing exercises to Nimlings! This guide outlines the process and conventions for adding new learning content.

## 1. Exercise File Structure and Naming

-   Exercises are located in the `exercises/` directory.
-   Each broad topic should have its own subdirectory within `exercises/`.
    -   Topic directory names should follow the pattern: `<topic_id>_<topic_name_lowercase_underscores>` (e.g., `01_variables`, `05_modules_stdlib`).
    -   The `topic_id` helps maintain a general order, though strict prerequisites are not heavily enforced by the tool itself yet.
-   Exercise files within a topic directory should be Nim source files (`.nim`).
-   Exercise file names should follow the pattern: `<topic_shortcode_or_type>_<exercise_number_in_topic>_<exercise_name_lowercase_underscores>.nim`
    -   Example: `var_1_declaration.nim`, `strutils_2_searching.nim`, `oop_1_simple_object.nim`.
    -   The `<topic_shortcode_or_type>` can be a brief identifier for the content (e.g., `if_else`, `seq`, `math`, `oop`).

## 2. Exercise Content Structure

Each exercise `.nim` file should contain the following main parts:

### a. Metadata Comment Block (at the top of the file)

This block consists of special comments that Nimlings parses to understand the exercise.

**Mandatory Fields:**

-   `# Description: <Your one-line description of the exercise's goal>`
    -   Example: `# Description: Learn to define and call a simple procedure.`
-   `# Hint: <Helpful hint or example for the user>`
    -   Can be multi-line if needed, but each line must start with `# Hint: `.
    -   Example: `# Hint: A procedure is a block of code. Define with 'proc name() = ...' and call with 'name()'.`
-   `# Points: <Integer>`
    -   Example: `# Points: 10`
-   `# SandboxPreference: <wasm|native>`
    *   Choose `wasm` if the exercise involves standard Nim features that are expected to work in a WASI environment (most algorithmic, data structure, pure stdlib function exercises).
    *   Choose `native` if the exercise requires direct OS interaction not typically available or easily/securely configurable in WASI (e.g., file I/O, networking, specific `os` module functions, complex macro behavior tied to native compilation).
    -   Example: `# SandboxPreference: wasm`
-   **Either** `# ExpectedOutput: ...` **or** `# ValidationScript: ...` (but not both usually)
    -   `# ExpectedOutput: <output_string_or_multiline_block>`
        -   If the output is a single line: `# ExpectedOutput: Hello, World!`
        -   If the output is multi-line, use the triple-backtick block syntax:
            ```nim
            # ExpectedOutput: ```
            # Line 1
            # Line 2
            # ```
            *(Note: In this markdown, the inner backticks are for display. In the .nim file, it's just `# ExpectedOutput: ````)*
    -   `# ValidationScript: <filename.nims>`
        -   Specifies a NimScript file (ending in `.nims`) located in the *same directory* as the exercise file.
        -   This script will be executed after the user's code. The user's code's stdout will be piped to the validation script's stdin.
        -   The validation script should exit with code 0 for success, non-zero for failure. Its output will be shown to the user.
        -   Example: `# ValidationScript: validate_my_exercise.nims`

**Optional Fields (Recommended for future use):**

-   `# Tags: <comma,separated,list,of,tags>`
    -   Example: `# Tags: basics, variables, integers`
-   `# Difficulty: <Easy|Medium|Hard>`
    -   Example: `# Difficulty: Easy`

### b. Starter Code for the User

This is the main body of the Nim code that the user will interact with.

-   **Imports**: Include necessary imports (e.g., `import strutils`, `import math`).
-   **Task Description/Breakdown**: Use comments to clearly explain what the user needs to do.
-   **`TODO:` Comments**: Place `# TODO:` comments where the user needs to write or modify code. Be specific.
    ```nim
    # TODO: Define your `greet` procedure here.

    # TODO: Call your `greet` procedure here to print "Hello!"
    ```
-   **Placeholder Lines**: Include a line like `echo "Exercise not fully implemented."` or more specific placeholders if parts of the solution are missing. This gives the user an indication if they run the file before completing it.
-   **`proc main() = ...` (Optional but common)**: For many exercises, wrapping the main logic in a `proc main() =` which is then called by the test block can be a clean way to structure it. For very simple exercises, top-level statements might be fine.

### c. Testing Block (for `nimlings run` and `nimlings watch`)

This block allows the exercise to be self-runnable and provides the basis for `ExpectedOutput` validation.

```nim
# Do not modify the lines below; they are for testing.
when defined(testMode):
  # Code that calls the user's solution with specific inputs
  # to generate the ExpectedOutput.
  # Example:
  # main()
  # or if main is not used:
  # let result = yourProcToTest(testInput)
  # echo result
else:
  # Code that runs when the user executes the file directly (e.g., `nim r my_exercise.nim`)
  # This can be a call to `main()` or provide different examples for manual testing.
  # Example:
  # main()
  # or:
  # echo "Running with sample inputs for manual testing:"
  # yourProcToTest(manualInput1)
  # yourProcToTest(manualInput2)
```
-   The `when defined(testMode):` block is crucial. Nimlings defines `testMode` when it compiles and runs an exercise. The output generated by this block is what's compared against `# ExpectedOutput:`.
-   The `else:` part of this `when` block is for when the user runs the file directly (e.g., `nim r exercises/topic/this_exercise.nim`). It can be the same as `testMode` or provide different examples.

## 3. Writing Good Exercises

-   **Clear Goal**: Each exercise should teach a specific, focused concept.
-   **Atomic**: Break down complex topics into smaller, manageable exercises.
-   **Clear Instructions**: Ensure `Description`, `Hint`, and `TODO` comments are unambiguous.
-   **Good Starter Code**: Provide enough context so the user knows where to begin, but not so much that the solution is trivial.
-   **Test Edge Cases**: If applicable, include test cases in your `when defined(testMode):` block that cover edge cases or common mistakes.
-   **Predictable `ExpectedOutput`**: If an exercise involves randomness or system-dependent output (like current time, file paths), use techniques to make the output predictable in `testMode` (e.g., fixed seeds for random, fixed dates for time, printing fixed strings for variable paths). If not possible, consider a `ValidationScript`.

## 4. Using the Metadata Linter

Before submitting, it's recommended to run the metadata linter:

```bash
nim compile -r tools/check_exercises.nim
```

This will check for common issues in your exercise file's metadata comments.

---

By following these guidelines, you can help create high-quality, consistent exercises that make learning Nim with Nimlings a great experience!
