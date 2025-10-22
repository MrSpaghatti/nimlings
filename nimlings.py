#!/usr/bin/env python3

"""
nimlings: An interactive command-line tutor for the Nim programming language.
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
import shutil
from lessons import LESSONS

# --- Configuration ---

CONFIG_DIR = Path.home() / ".config" / "nimlings"
PROGRESS_FILE = CONFIG_DIR / "progress.json"
STATE_FILE = CONFIG_DIR / "state.json"

# --- Tutorial Content ---

# --- Core Application Logic ---

def check_nim_installed():
    """Exits if 'nim' command is not found."""
    try:
        subprocess.run(
            ["nim", "--version"],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Hard to teach you Nim if you don't have it installed, genius. Go fix that.")
        sys.exit(1)


def load_progress() -> set:
    """Loads the set of completed lesson IDs from the progress file."""
    if not PROGRESS_FILE.exists():
        return set()
    try:
        with open(PROGRESS_FILE, "r", encoding="utf-8") as f:
            return set(json.load(f))
    except (json.JSONDecodeError, IOError):
        print(f"Warning: Could not read or parse progress file at {PROGRESS_FILE}. Starting fresh.")
        return set()


def save_progress(completed_ids: set):
    """Saves the set of completed lesson IDs."""
    try:
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        with open(PROGRESS_FILE, "w", encoding="utf-8") as f:
            json.dump(list(completed_ids), f)
    except IOError:
        print(f"Fatal: Could not write progress to {PROGRESS_FILE}. Progress will not be saved.")
        sys.exit(1)


def load_state() -> dict:
    """Loads the user's last active lesson state."""
    if not STATE_FILE.exists():
        return {}
    try:
        with open(STATE_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return {}


def save_state(lesson_id: str):
    """Saves the user's last active lesson state."""
    try:
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        with open(STATE_FILE, "w", encoding="utf-8") as f:
            json.dump({"last_lesson": lesson_id}, f)
    except IOError:
        print(f"Warning: Could not write state to {STATE_FILE}. Hint functionality may be impaired.")


def get_editor() -> str:
    """Returns the user's preferred text editor, defaulting to nano."""
    editor = os.environ.get("EDITOR")
    if editor:
        return editor
    if shutil.which("vim"):
        return "vim"
    return "nano"


def run_code(filepath: Path) -> subprocess.CompletedProcess:
    """Compiles and runs a Nim source file."""
    return subprocess.run(
        ["nim", "c", "-r", "--threads:on", str(filepath)],
        capture_output=True,
        text=True,
        encoding='utf-8',
    )


def _present_lesson(lesson: dict):
    """Prints the lesson's concept and task."""
    print("---")
    print(f"Module {lesson['id'].split('.')[0]} - Lesson {lesson['id']}: {lesson['name']}")
    print("---\n")
    print(lesson["concept"])
    print("\n" + "=" * 20)
    print("TASK:", lesson["task"])
    print("=" * 20 + "\n")


def _get_code_from_editor(tmp_filepath: Path):
    """Opens the user's editor and returns the code they wrote."""
    editor = get_editor()
    print(f"Opening your editor ({editor}). Save and close the file when you're done.")
    proc = subprocess.run([editor, str(tmp_filepath)], check=False)
    if proc.returncode != 0:
        print(f"\nEditor exited with a non-zero status. Not even trying to compile that.")
        return None

    user_code = tmp_filepath.read_text(encoding="utf-8")
    if not user_code.strip():
        print("\nYou didn't write anything. Can't pass a lesson if you don't try.")
        return None
    return user_code


def _check_solution(lesson: dict, user_code: str, result: subprocess.CompletedProcess, quiet: bool = False) -> bool:
    """Checks the user's solution and prints feedback."""
    if result.returncode != 0:
        print("\n--- COMPILE ERROR ---")
        print("You wrote:\n---\n" + user_code + "\n---")
        print("Yeah, that didn't work. The compiler spit this back at you:")
        print(result.stderr)
        print("\nHINT:", lesson["hint"])
        return False

    if lesson["validation"](user_code, result):
        if not quiet:
            print("\nAlright, that works. Don't get cocky.")
        return True

    print("\n--- LOGIC ERROR ---")
    print("You wrote:\n---\n" + user_code + "\n---")
    print("It compiled, but it's wrong. Your code produced this output:")
    print(f"```\n{result.stdout.strip()}\n```")
    print("\nThat's not what was asked for. Try again.")
    return False


def _get_lesson_by_id(lesson_id: str) -> dict | None:
    """Finds a lesson by its ID."""
    for module in LESSONS:
        for lesson in module["lessons"]:
            if lesson["id"] == lesson_id:
                return lesson
    return None


def run_lesson(lesson: dict) -> bool:
    """
    Guides the user through a single lesson.
    Returns True if the lesson was completed, False otherwise.
    """
    _present_lesson(lesson)

    if not lesson.get("validation"):  # For intro-style lessons
        input("Press Enter to continue...")
        return True

    with tempfile.NamedTemporaryFile(mode="w+", delete=False, suffix=".nim", encoding='utf-8') as tmp_file:
        tmp_filepath = Path(tmp_file.name)

    try:
        user_code = _get_code_from_editor(tmp_filepath)
        if user_code is None:
            return False

        print("Compiling and running your masterpiece...")
        result = run_code(tmp_filepath)
        return _check_solution(lesson, user_code, result)

    finally:
        if tmp_filepath.exists():
            tmp_filepath.unlink()

# --- Command Handlers ---

def handle_learn(progress: set, lesson_id: str | None) -> str | None:
    """
    Determines which lesson to run, runs it, and returns the next lesson's ID.
    Returns None if the tutorial is complete or if the lesson fails.
    """
    lesson_to_run = None
    if lesson_id:
        lesson_to_run = _get_lesson_by_id(lesson_id)
        if not lesson_to_run:
            print(f"Lesson '{lesson_id}' not found. What are you even trying to do?")
            return None
    else:
        state = load_state()
        last_lesson_id = state.get("last_lesson")
        if last_lesson_id:
             lesson_to_run = _get_lesson_by_id(last_lesson_id)

        if not lesson_to_run:
            for module in LESSONS:
                for lesson in module["lessons"]:
                    if lesson["id"] not in progress:
                        lesson_to_run = lesson
                        break
                if lesson_to_run:
                    break

    if not lesson_to_run:
        print("\nWell, look at you. You actually finished everything. Now go build something.")
        return None

    save_state(lesson_to_run["id"])

    if run_lesson(lesson_to_run):
        progress.add(lesson_to_run["id"])
        save_progress(progress)
        print("\nLesson complete. Moving on.")

        flat_lessons = [lesson for module in LESSONS for lesson in module["lessons"]]
        current_index = next((i for i, lesson in enumerate(flat_lessons) if lesson["id"] == lesson_to_run["id"]), -1)

        if current_index != -1 and current_index + 1 < len(flat_lessons):
            return flat_lessons[current_index + 1]["id"]
        else:
            return None # End of the line
    else:
        print("\nLesson failed. Come back when you're ready to try again.")
        return None


def handle_test():
    """Runs the solution for every lesson and validates it."""
    print("Running internal tests...")
    failed_lessons = []
    flat_lessons = [lesson for module in LESSONS for lesson in module["lessons"]]

    for lesson in flat_lessons:
        if not lesson.get("validation"):
            continue

        print(f"Testing {lesson['id']}: {lesson['name']}...")
        solution_code = lesson.get("solution")
        if not solution_code:
            print(f"SKIPPED: No solution provided for {lesson['id']}")
            continue

        with tempfile.NamedTemporaryFile(mode="w+", delete=False, suffix=".nim", encoding='utf-8', prefix="nimlings_test_") as tmp_file:
            tmp_filepath = Path(tmp_file.name)
            tmp_filepath.write_text(solution_code, encoding='utf-8')

        try:
            result = run_code(tmp_filepath)
            if not _check_solution(lesson, solution_code, result, quiet=True):
                failed_lessons.append(lesson["id"])
        finally:
            if tmp_filepath.exists():
                tmp_filepath.unlink()

    if not failed_lessons:
        print("\nAll lessons passed. Nice.")
    else:
        print(f"\nTest failed for the following lessons: {', '.join(failed_lessons)}")


def handle_hint(lesson_id: str | None):
    """Shows a hint for the current or a specific lesson."""
    lesson_to_hint = None
    if lesson_id:
        lesson_to_hint = _get_lesson_by_id(lesson_id)
    else:
        state = load_state()
        last_lesson_id = state.get("last_lesson")
        if last_lesson_id:
            lesson_to_hint = _get_lesson_by_id(last_lesson_id)

    if not lesson_to_hint:
        print("Not sure what you want a hint for. Try `nimlings learn` first.")
        return

    if "hint" in lesson_to_hint:
        print(f"HINT for {lesson_to_hint['id']}: {lesson_to_hint['hint']}")
    else:
        print(f"Lesson {lesson_to_hint['id']} doesn't have a hint. You're on your own, kid.")


def handle_solution(lesson_id: str | None):
    """Shows the solution for the current or a specific lesson."""
    lesson_to_solve = None
    if lesson_id:
        lesson_to_solve = _get_lesson_by_id(lesson_id)
    else:
        state = load_state()
        last_lesson_id = state.get("last_lesson")
        if last_lesson_id:
            lesson_to_solve = _get_lesson_by_id(last_lesson_id)

    if not lesson_to_solve:
        print("Not sure which solution you want. Try `nimlings learn` first.")
        return

    solution = lesson_to_solve.get("solution")
    if solution:
        print(f"--- SOLUTION for {lesson_to_solve['id']} ---\n{solution}\n---")
    else:
        print(f"Lesson {lesson_to_solve['id']} doesn't have a solution. This is probably a bug.")


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
        files_removed = False
        for f in [PROGRESS_FILE, STATE_FILE]:
            if f.exists():
                try:
                    f.unlink()
                    files_removed = True
                except IOError:
                    print(f"Error: Could not delete {f}.")

        if files_removed:
            print("Progress wiped. Back to square one.")
        else:
            print("You had no progress to wipe. So, uh, I did nothing.")
    else:
        print("Reset cancelled. Your mediocrity is safe for now.")


def main():
    """Main entry point and argument parsing."""
    check_nim_installed()

    parser = argparse.ArgumentParser(
        description="nimlings: An interactive tutor for the Nim programming language.",
        epilog="Run `nimlings` with no arguments to start or resume your learning."
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    learn_parser = subparsers.add_parser("learn", help="Start or resume the tutorial (default).")
    learn_parser.add_argument("lesson_id", nargs="?", help="Jump to a specific lesson.")
    hint_parser = subparsers.add_parser("hint", help="Get a hint for a lesson.")
    hint_parser.add_argument("lesson_id", nargs="?", help="Get a hint for a specific lesson.")
    solution_parser = subparsers.add_parser("solution", help="Show the solution for a lesson.")
    solution_parser.add_argument("lesson_id", nargs="?", help="Show the solution for a specific lesson.")
    subparsers.add_parser("list", help="List all lessons and your progress.")
    subparsers.add_parser("reset", help="Reset your progress.")
    subparsers.add_parser("test", help="Run the internal lesson tests.")

    args = parser.parse_args()
    command = args.command if args.command else "learn"

    progress = load_progress()

    if command == "learn":
        print("Welcome to nimlings. Let's see what you know, or more likely, what you don't.")
        next_lesson_id = args.lesson_id
        while True:
            next_lesson_id = handle_learn(progress, next_lesson_id)
            if next_lesson_id is None:
                break
            # If a specific lesson was requested, don't loop
            if args.lesson_id:
                break
    elif command == "list":
        handle_list(progress)
    elif command == "hint":
        handle_hint(args.lesson_id)
    elif command == "solution":
        handle_solution(args.lesson_id)
    elif command == "reset":
        handle_reset()
    elif command == "test":
        handle_test()
    else:
        parser.print_help()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nQuitting. Can't handle the heat, huh?")
        sys.exit(0)
