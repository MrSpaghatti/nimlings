import argparse
import sys
from pathlib import Path
from engine import Engine
from tui import TUIApp

def main():
    """Main entry point."""
    engine = Engine()
    engine.check_nim_installed()

    parser = argparse.ArgumentParser(
        description="nimlings: An interactive tutor for the Nim programming language.",
        epilog="Run `nimlings` with no arguments to start the TUI."
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    learn_parser = subparsers.add_parser("learn", help="Start the TUI (default).")
    learn_parser.add_argument("lesson_id", nargs="?", help="Jump to a specific lesson in TUI.") # TUI handles this state
    
    # Legacy CLI commands
    subparsers.add_parser("list", help="List all lessons and your progress.")
    subparsers.add_parser("reset", help="Reset your progress.")
    subparsers.add_parser("test", help="Run the internal lesson tests.")
    # Removed hint/solution CLI commands as they are better in TUI, but kept for legacy if needed?
    # Let's keep them for quick access.
    hint_parser = subparsers.add_parser("hint", help="Get a hint for a lesson.")
    hint_parser.add_argument("lesson_id", nargs="?", help="Get a hint for a specific lesson.")
    sol_parser = subparsers.add_parser("solution", help="Show solution.")
    sol_parser.add_argument("lesson_id", nargs="?", help="Lesson ID.")


    args = parser.parse_args()
    command = args.command if args.command else "learn"
    
    # Handle CLI-only commands
    if command == "list":
        progress = engine.load_progress()
        print("Here's the curriculum. `[x]` means you managed to get it right.")
        for module in engine.lessons:
            print(f"\n{module['module']}")
            for lesson in module["lessons"]:
                marker = "[x]" if lesson["id"] in progress else "[ ]"
                print(f"  {marker} {lesson['id']}: {lesson['name']}")
                
    elif command == "reset":
        if engine.reset_progress():
            print("Progress wiped.")
        else:
            print("Nothing to reset.")
            
    elif command == "test":
        # Re-implement test logic using Engine
        print("Running internal tests...")
        failed_lessons = []
        flat_lessons = [lesson for module in engine.lessons for lesson in module["lessons"]]
        
        for lesson in flat_lessons:
            if not lesson.get("validation"): continue
            print(f"Testing {lesson['id']}: {lesson['name']}...")
            solution_code = lesson.get("solution")
            if not solution_code: continue
            
            import tempfile
            with tempfile.TemporaryDirectory() as tmp_dir:
                fname = lesson.get("filename", "test_sol.nim")
                tmp_path = Path(tmp_dir) / fname
                tmp_path.parent.mkdir(parents=True, exist_ok=True)
                tmp_path.write_text(solution_code, encoding='utf-8')
                result = engine.run_code(
                    tmp_path,
                    args=lesson.get("args"),
                    project_files=lesson.get("files"),
                    compile_cmd=lesson.get("cmd", "c"),
                    project_root=Path(tmp_dir),
                    skip_run=lesson.get("skip_run", False),
                    compiler_args=lesson.get("compiler_args")
                )
                success, msg = engine.validate_lesson(lesson, solution_code, result)
                if not success:
                    print(f"FAIL {lesson['id']}: {msg}")
                    failed_lessons.append(lesson["id"])
        
        if failed_lessons:
            print(f"Failed: {failed_lessons}")
            sys.exit(1)
        else:
            print("All passed.")

    elif command == "hint":
        # Simple CLI hint
        lid = getattr(args, "lesson_id", None)
        if not lid:
             state = engine.load_state()
             lid = state.get("last_lesson")
        lesson = engine.get_lesson_by_id(lid) if lid else None
        if lesson:
            print(f"HINT: {lesson.get('hint', 'None')}")
        else:
            print("Lesson not found.")

    elif command == "solution":
        lid = getattr(args, "lesson_id", None)
        if not lid:
             state = engine.load_state()
             lid = state.get("last_lesson")
        lesson = engine.get_lesson_by_id(lid) if lid else None
        if lesson:
             print(f"SOLUTION:\n{lesson.get('solution', 'None')}")
        else:
             print("Lesson not found.")

    else:
        # Default: Run TUI
        # If lesson_id provided, save it to state first so TUI picks it up
        lid = getattr(args, "lesson_id", None)
        if lid:
             engine.save_state(lid)
        
        app = TUIApp(engine)
        app.run()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass