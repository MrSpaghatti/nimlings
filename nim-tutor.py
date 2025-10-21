#!/usr/bin/env python3

"""
nim-tutor: An interactive command-line tutor for the Nim programming language.
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

# --- Configuration ---

CONFIG_DIR = Path.home() / ".config" / "nim-tutor"
PROGRESS_FILE = CONFIG_DIR / "progress.json"

# --- Tutorial Content ---

LESSONS = [
    {
        "module": "1: The Basics (\"Why Bother?\")",
        "lessons": [
            {
                "id": "1.1",
                "name": "Intro",
                "concept": (
                    "Alright, let's get this over with. You're here to learn Nim.\n"
                    "It's a compiled, statically typed language that looks like Python but has the performance of C.\n"
                    "This means you get speed, but you also have to actually think about your types.\n"
                    "No more sloppy dynamic-language nonsense."
                ),
                "task": "There's no code to write. Just read the above and internalize it. Press Enter to continue.",
            },
            {
                "id": "1.2",
                "name": "Hello World",
                "concept": (
                    "Your first rite of passage. In Nim, the `echo` procedure prints stuff to the console.\n"
                    "It's simple, clean, and gets the job done. Don't overthink it."
                ),
                "task": "Write a single line of Nim code that prints the string \"Hello, Nim!\".",
                "validation": lambda code, result: result.stdout.strip() == "Hello, Nim!",
                "hint": "Just `echo` the exact string. With quotes. You can figure this out.",
            },
            {
                "id": "1.3",
                "name": "Compiling & Running",
                "concept": (
                    "Nim is a compiled language. The command `nim c -r your_file.nim` does two things:\n"
                    "1. `c`: Compiles your Nim code into a C executable.\n"
                    "2. `-r` or `--run`: Runs the resulting executable immediately after compiling.\n"
                    "This is the workflow you'll use constantly. Get used to it."
                ),
                "task": "Write a program that prints the number 42.",
                "validation": lambda code, result: result.stdout.strip() == "42",
                "hint": "Same as before. `echo` the number. No quotes this time, genius.",
            },
        ],
    },
    {
        "module": "2: Variables & Data Types (\"Storing Your Junk\")",
        "lessons": [
            {
                "id": "2.1",
                "name": "let vs var",
                "concept": (
                    "Nim has two ways to declare variables: `let` and `var`.\n"
                    "- `let` creates an immutable variable. Once assigned, you can't change it. It's a constant.\n"
                    "- `var` creates a mutable variable. You can change its value whenever you want.\n"
                    "Rule of thumb: Use `let` by default. Mutability is a footgun. Only use `var` when you know you need it."
                ),
                "task": "Declare an immutable string named `name` with the value \"Nim\" and a mutable integer `age` with the value 15. The program shouldn't print anything.",
                "validation": lambda code, result: result.returncode == 0,
                "hint": "The syntax is `let name = \"value\"` and `var age = 15`. If it compiles, you did it right.",
            },
            {
                "id": "2.2",
                "name": "Basic Types",
                "concept": (
                    "Nim is statically typed. You can, and often should, declare types explicitly.\n"
                    "The syntax is `var name: type = value`.\n"
                    "Basic types include: `int`, `string`, `float`, `bool`."
                ),
                "task": "Declare four `var` variables, one of each basic type: an `int` named `i`, a `string` named `s`, a `float` named `f`, and a `bool` named `b`. Assign them any valid values. No output needed.",
                "validation": lambda code, result: result.returncode == 0,
                "hint": "Example: `var i: int = 10`. Do that for all four types.",
            },
            {
                "id": "2.3",
                "name": "Type Inference",
                "concept": (
                    "Explicitly writing types is good, but sometimes the compiler can figure it out.\n"
                    "Using `:=` instead of `=` for the first assignment lets Nim infer the type.\n"
                    "`let name = \"Nim\"` is the same as `let name: string = \"Nim\"`.\n"
                    "`var age := 20` is the same as `var age: int = 20`.\n"
                    "This only works on the first assignment."
                ),
                "task": "Declare a mutable integer named `counter` with a value of 0 using type inference.",
                "validation": lambda code, result: result.returncode == 0,
                "hint": "You need a mutable variable, so use `var`. And for inference, use `:=`.",
            },
        ],
    },
    {
        "module": "3: Procedures & Control Flow (\"Actually Doing Stuff\")",
        "lessons": [
            {
                "id": "3.1",
                "name": "Procedures (proc)",
                "concept": (
                    "Procedures, or `proc`, are Nim's functions. They take arguments and can return a value.\n"
                    "The syntax is: `proc name(arg1: type, arg2: type): returntype =`\n"
                    "The body of the proc is indented. The return value is the last expression, or you can use `return`."
                ),
                "task": "Write a procedure named `addNumbers` that takes two integers (`a` and `b`) and returns their sum. Then, call it with `5` and `10` and `echo` the result.",
                "validation": lambda code, result: result.stdout.strip() == "15",
                "hint": "Define the proc first. `proc addNumbers(a: int, b: int): int = a + b`. Then, on a new line, `echo addNumbers(5, 10)`.",
            },
            {
                "id": "3.2",
                "name": "if/else/elif",
                "concept": (
                    "Conditional logic. You've seen this before in other languages. It's not complicated.\n"
                    "`if condition:`\n"
                    "  `...`\n"
                    "`elif other_condition:`\n"
                    "  `...`\n"
                    "`else:`\n"
                    "  `...`"
                ),
                "task": (
                    "Write a procedure `checkSign` that takes an integer.\n"
                    "- If the number is greater than 0, it should `echo` \"Positive\".\n"
                    "- If it's less than 0, it should `echo` \"Negative\".\n"
                    "- Otherwise, it should `echo` \"Zero\".\n"
                    "Call your procedure with the number -5."
                ),
                "validation": lambda code, result: result.stdout.strip() == "Negative",
                "hint": "Your `if` condition should be `num > 0`, `elif` should be `num < 0`, and `else` handles the rest.",
            },
            {
                "id": "3.3",
                "name": "for Loops",
                "concept": (
                    "Looping. `for i in a..b:` will loop from `a` to `b`, inclusive.\n"
                    "It's a simple, readable way to iterate."
                ),
                "task": "Write a `for` loop that prints the numbers from 1 to 5, each on a new line.",
                "validation": lambda code, result: result.stdout.strip() == "1\n2\n3\n4\n5",
                "hint": "Use `for num in 1..5:`. Inside the loop, `echo num`.",
            },
        ],
    },
]

# --- Core Application Logic ---

def check_nim_installed():
    """Exits if 'nim' command is not found."""
    try:
        subprocess.run(
            ["nim", "--version"],
            check=True,
            capture_output=True,
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Hard to teach you Nim if you don't have it installed, genius. Go fix that.")
        sys.exit(1)


def load_progress() -> set:
    """Loads the set of completed lesson IDs from the progress file."""
    if not PROGRESS_FILE.exists():
        return set()
    try:
        with open(PROGRESS_FILE, "r") as f:
            return set(json.load(f))
    except (json.JSONDecodeError, IOError):
        print(f"Warning: Could not read or parse progress file at {PROGRESS_FILE}. Starting fresh.")
        return set()


def save_progress(completed_ids: set):
    """Saves the set of completed lesson IDs."""
    try:
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        with open(PROGRESS_FILE, "w") as f:
            json.dump(list(completed_ids), f)
    except IOError:
        print(f"Fatal: Could not write progress to {PROGRESS_FILE}. Progress will not be saved.")
        sys.exit(1)


def get_editor() -> str:
    """Returns the user's preferred text editor, defaulting to nano."""
    return os.environ.get("EDITOR", "nano")


def run_code(filepath: Path) -> subprocess.CompletedProcess:
    """Compiles and runs a Nim source file."""
    return subprocess.run(
        ["nim", "c", "-r", str(filepath)],
        capture_output=True,
        text=True,
        encoding='utf-8',
    )


def run_lesson(lesson: dict) -> bool:
    """
    Guides the user through a single lesson.
    Returns True if the lesson was completed, False otherwise.
    """
    print("---")
    print(f"Module {lesson['id'].split('.')[0]} - Lesson {lesson['id']}: {lesson['name']}")
    print("---\n")
    print(lesson["concept"])
    print("\n" + "=" * 20)
    print("TASK:", lesson["task"])
    print("=" * 20 + "\n")

    if not lesson.get("validation"): # For intro-style lessons
        input("Press Enter to continue...")
        return True

    editor = get_editor()
    with tempfile.NamedTemporaryFile(mode="w+", delete=False, suffix=".nim", encoding='utf-8') as tmp_file:
        tmp_filepath = Path(tmp_file.name)

    try:
        print(f"Opening your editor ({editor}). Save and close the file when you're done.")
        proc = subprocess.run([editor, str(tmp_filepath)], check=False)
        if proc.returncode != 0:
            print(f"\nEditor exited with a non-zero status. Not even trying to compile that.")
            return False

        user_code = tmp_filepath.read_text()
        if not user_code.strip():
            print("\nYou didn't write anything. Can't pass a lesson if you don't try.")
            return False

        print("Compiling and running your masterpiece...")
        result = run_code(tmp_filepath)

        if result.returncode != 0:
            print("\n--- COMPILE ERROR ---")
            print("Yeah, that didn't work. The compiler spit this back at you:")
            print(result.stderr)
            print("\nHINT:", lesson["hint"])
            return False

        if lesson["validation"](user_code, result):
            print("\nAlright, that works. Don't get cocky.")
            return True
        else:
            print("\n--- LOGIC ERROR ---")
            print("It compiled, but it's wrong. Your code produced this output:")
            print(f"```\n{result.stdout.strip()}\n```")
            print("\nThat's not what was asked for. Try again.")
            return False

    finally:
        if tmp_filepath.exists():
            tmp_filepath.unlink()

# --- Command Handlers ---

def handle_learn(progress: set):
    """Starts the tutorial from the next uncompleted lesson."""
    print("Welcome to nim-tutor. Let's see what you know, or more likely, what you don't.")
    next_lesson = None
    for module in LESSONS:
        for lesson in module["lessons"]:
            if lesson["id"] not in progress:
                next_lesson = lesson
                break
        if next_lesson:
            break

    if not next_lesson:
        print("\nWell, look at you. You actually finished everything. Now go build something.")
        return

    if run_lesson(next_lesson):
        progress.add(next_lesson["id"])
        save_progress(progress)
        print("\nLesson complete. Moving on.")
        handle_learn(progress) # Recurse to start the next lesson automatically
    else:
        print("\nLesson failed. Come back when you're ready to try again.")


def handle_list(progress: set):
    """Lists all lessons and their completion status."""
    print("Here's the curriculum. `[x]` means you managed to get it right.")
    for module in LESSONS:
        print(f"\n{module['module']}")
        for lesson in module["lessons"]:
            marker = "[x]" if lesson["id"] in progress else "[ ]"
            print(f"  {marker} {lesson['id']}: {lesson['name']}")


def handle_reset():
    """Deletes the user's progress."""
    confirm = input("Really nuke all your progress? This can't be undone. (y/n): ").lower()
    if confirm == "y":
        if PROGRESS_FILE.exists():
            try:
                PROGRESS_FILE.unlink()
                print("Progress wiped. Back to square one.")
            except IOError:
                print(f"Error: Could not delete {PROGRESS_FILE}.")
        else:
            print("You had no progress to wipe. So, uh, I did nothing.")
    else:
        print("Reset cancelled. Your mediocrity is safe for now.")


def main():
    """Main entry point and argument parsing."""
    check_nim_installed()

    parser = argparse.ArgumentParser(
        description="nim-tutor: An interactive tutor for the Nim programming language.",
        epilog="Run `nim-tutor` with no arguments to start or resume your learning."
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    subparsers.add_parser("learn", help="Start or resume the tutorial (default).")
    subparsers.add_parser("list", help="List all lessons and your progress.")
    subparsers.add_parser("reset", help="Reset your progress.")

    args = parser.parse_args()
    command = args.command if args.command else "learn"

    progress = load_progress()

    if command == "learn":
        handle_learn(progress)
    elif command == "list":
        handle_list(progress)
    elif command == "reset":
        handle_reset()
    else:
        parser.print_help()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nQuitting. Can't handle the heat, huh?")
        sys.exit(0)
