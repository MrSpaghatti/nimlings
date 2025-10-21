# Nimlings - Learn Nim Interactively!

Welcome to Nimlings! This is a command-line tool designed to help you learn the Nim programming language through a series of small, interactive exercises. It's inspired by similar "*-lings" projects in other language ecosystems (like Rustlings).

The core philosophy is "learn by fixing": you'll encounter exercises that are often incomplete or contain deliberate errors. Your task is to fix them, guided by the Nim compiler's feedback and hints provided within each exercise.

## Features

*   **Interactive Exercises**: A growing collection of exercises covering various Nim concepts, from basic syntax to more advanced topics.
*   **Structured Learning**: Exercises are organized into topics, allowing for progressive learning.
*   **Hints**: Each exercise comes with hints to guide you if you get stuck.
*   **Points & Badges**: Earn points for completing exercises and unlock badges for milestones.
*   **Watch Mode**: Automatically re-run an exercise when you save changes to its file (`nimlings watch`).
*   **REPL (Shell)**: A basic interactive shell (`nimlings shell`) for quick experimentation with Nim code.
*   **Sandbox Execution (PoC)**: Exercises can be run in different environments, including a WebAssembly (WASM) sandbox using Wasmer (still experimental and for learning purposes, not a security guarantee for untrusted code).
*   **Progress Tracking**: Nimlings remembers your completed exercises.

## Getting Started (Conceptual - Tool Not Yet Packaged for Distribution)

While Nimlings is under development, here's how you would typically use it once packaged or run from source:

1.  **Installation**:
    *   (Future) Download a pre-compiled binary for your system.
    *   (Current) Compile from source: `nim compile -r src/nimlings.nim --help` (to see all commands).

2.  **List Exercises**:
    ```bash
    nimlings list
    ```
    This shows all available exercises, their status (TODO/DONE), topic, points, and description.
    You can filter the list:
    ```bash
    nimlings list --topicFilter="02_control_flow"
    nimlings list --statusFilter=todo
    nimlings list --searchTerm="fibonacci"
    ```

3.  **Run an Exercise**:
    Navigate to an exercise file (e.g., `exercises/00_introduction/intro1_helloworld.nim`). Read its description and hints, then edit the file to complete the TODOs.
    To run and check your solution:
    ```bash
    nimlings run exercises/00_introduction/intro1_helloworld.nim
    ```
    Or, more simply, by its name if unique:
    ```bash
    nimlings run intro1_helloworld
    ```

4.  **Watch Mode**:
    For a faster feedback loop, use watch mode on the next pending exercise:
    ```bash
    nimlings watch
    ```
    Or for a specific exercise:
    ```bash
    nimlings watch intro1_helloworld
    ```
    Nimlings will automatically re-run the exercise whenever you save the file.

5.  **Get a Hint**:
    If you're stuck on an exercise:
    ```bash
    nimlings hint intro1_helloworld
    ```

6.  **Check Your Status**:
    See your points, completed exercises, and earned badges:
    ```bash
    nimlings status
    ```

7.  **Interactive Shell**:
    For quick experiments:
    ```bash
    nimlings shell
    ```
    Type Nim code, enter a blank line or `:run` to execute. Use `:help` in the shell for more commands.

## Curriculum Topics (Current & Expanding)

*   `00_cli_basics`: Understanding the command line.
*   `00_introduction`: Your very first Nim code.
*   `01_variables`: Declaring and using variables.
*   `02_control_flow`: `if/else`, `case`, `while`, `for` loops.
*   `03_procedures`: Defining and calling procedures and functions.
*   `04_collections`: `seq`, `array`, `string`, `Table`, `HashSet`, `tuple`.
*   `05_modules_stdlib`: Using standard library modules (`math`, `strutils`, `sequtils`, `random`) and custom modules.
*   `06_error_handling`: `try/except`, `try/finally`, `raise`, custom exceptions.
*   `07_oop_basics`: Objects, methods, basic inheritance, converters, `ref object`.
*   `08_generics`: Generic procedures, functions, objects, and type constraints.
*   `09_file_io`: Reading and writing files.
*   `10_functional_programming`: Pure functions, higher-order functions, recursion.
*   `11_dynamic_programming`: Introduction to memoization and tabulation (Fibonacci, grid path).
*   `12_metaprogramming`: Introduction to templates and simple macros.
*   `13_stdlib_json`: Parsing and generating JSON.
*   `14_stdlib_os`: Path operations, file/dir checks, listing, environment variables.
*   `15_stdlib_times`: Working with dates, times, and durations.
*   `16_stdlib_networking`: Basic HTTP GET requests.
*   ... and more to come!

## Contributing

If you're interested in contributing exercises or improving Nimlings, please see `CONTRIBUTING_EXERCISES.md` and the general contribution guidelines for this project (if available).

We welcome contributions to expand the curriculum and enhance the tool!

## Disclaimer

Nimlings is a learning tool. While it includes an experimental WASM sandbox, always be cautious when running code from any source. The primary goal of the sandbox in Nimlings is to provide a somewhat isolated environment for standard exercises, not to be a hardened security boundary against malicious code.

---

Happy Nim-learning with Nimlings!
