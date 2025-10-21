# nimlings

`nimlings` is an interactive command-line application designed to teach the basics of the Nim programming language. It's a single, self-contained Python script that you can run directly.

The tutor presents you with a concept, gives you a coding task, and then opens your default text editor for you to write a solution. It then compiles and runs your code, providing immediate feedback. All in a cynical, no-bullshit tone.

## Prerequisites

1.  **Python 3**: The script is written in Python 3. You'll need it installed to run the tutor.
2.  **Nim Compiler**: The tutor uses the `nim` compiler to check your code. You must have Nim installed and available in your system's `PATH`. You can find installation instructions on the [official Nim website](https://nim-lang.org/install.html).

## How to Use

1.  **Make the script executable**:
    ```sh
    chmod +x nimlings.py
    ```

2.  **Run a command**:
    The script is executed as `./nimlings.py` followed by one of the commands below.

## Commands

### `learn` (Default)

Starts the tutorial or resumes from your last uncompleted lesson. If you run the script with no command, `learn` is used by default.

```sh
./nimlings.py learn
# or simply
./nimlings.py
```

### `list`

Lists all the modules and lessons in the curriculum. Lessons you have already completed will be marked with `[x]`.

```sh
./nimlings.py list
```

### `reset`

Deletes all your progress, allowing you to start the tutorial from the very beginning. It will ask for confirmation before wiping your progress file (`~/.config/nimlings/progress.json`).

```sh
./nimlings.py reset
```
