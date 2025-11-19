import argparse
import sys
import tempfile
from pathlib import Path
from src.engine import Engine
from src.tui import TUIApp
from src.exceptions import NimlingsError

def main():
    """Main entry point."""
    try:
        engine = Engine()
        engine.check_nim_installed()

        parser = argparse.ArgumentParser(
            description="nimlings: An interactive tutor for the Nim programming language.",
            epilog="Run `nimlings` with no arguments to start the TUI."
        )
        subparsers = parser.add_subparsers(dest="command", help="Available commands")

        learn_parser = subparsers.add_parser("learn", help="Start the TUI (default).")
        learn_parser.add_argument("lesson_id", nargs="?", help="Jump to a specific lesson in TUI.")  
        list_parser = subparsers.add_parser("list", help="List all lessons and your progress.")
        reset_parser = subparsers.add_parser("reset", help="Reset your progress.")
        test_parser = subparsers.add_parser("test", help="Run the internal lesson tests.")
        hint_parser = subparsers.add_parser("hint", help="Get a hint for a lesson.")
        hint_parser.add_argument("lesson_id", help="Lesson ID to get hint for.")
        solution_parser = subparsers.add_parser("solution", help="Show solution.")
        solution_parser.add_argument("lesson_id", help="Lesson ID to show solution for.")

        args = parser.parse_args()

        # Default to learn if no command
        if not args.command:
            args.command = "learn"

        if args.command == "learn":
            app = TUIApp(engine)
            app.run()

        elif args.command == "list":
            progress = engine.load_progress()
            print("=== Nimlings Curriculum ===\n")
            for module in engine.lessons:
                print(f"{module['name']}:")
                for lesson in module['lessons']:
                    marker = "[x]" if lesson['id'] in progress else "[ ]"
                    print(f"  {marker} {lesson['id']}: {lesson['name']}")
                print()

        elif args.command == "reset":
            if engine.reset_progress():
                print("Progress reset.")
            else:
                print("Nothing to reset.")

        elif args.command == "test":
            print("Running internal tests...")
            passed = 0
            failed = 0
            for module in engine.lessons:
                for lesson in module['lessons']:
                    if not lesson.get("validation"):
                        continue  # Skip intro lessons
                    
                    print(f"Testing {lesson['id']}: {lesson['name']}...")
                    
                    with tempfile.TemporaryDirectory() as tmp_dir:
                        fname = lesson.get("filename", "solution.nim")
                        tmp_path = Path(tmp_dir) / fname
                        tmp_path.parent.mkdir(parents=True, exist_ok=True)
                        tmp_path.write_text(lesson['solution'], encoding="utf-8")
                        
                        result = engine.run_code(
                            tmp_path,
                            args=lesson.get("args"),
                            project_files=lesson.get("files"),
                            compile_cmd=lesson.get("cmd", "c"),
                            project_root=Path(tmp_dir),
                            skip_run=lesson.get("skip_run", False),
                            compiler_args=lesson.get("compiler_args")
                        )
                        
                        success, msg = engine.validate_lesson(lesson, lesson['solution'], result)
                        if success:
                            passed += 1
                        else:
                            failed += 1
                            print(msg)
            
            if failed > 0:
                print(f"\nPassed: {passed}, Failed: {failed}")
                sys.exit(1)
            else:
                print("All passed.")

        elif args.command == "hint":
            lesson = engine.get_lesson_by_id(args.lesson_id)
            print(f"=== Hint for {lesson['id']}: {lesson['name']} ===\n")
            print(lesson['hint'])

        elif args.command == "solution":
            lesson = engine.get_lesson_by_id(args.lesson_id)
            print(f"=== Solution for {lesson['id']}: {lesson['name']} ===\n")
            print(lesson['solution'])
    
    except NimlingsError as e:
        # Our custom exceptions with helpful messages
        print(f"\n{'='*60}", file=sys.stderr)
        print(f"ERROR: {e}", file=sys.stderr)
        print(f"{'='*60}\n", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nInterrupted by user.", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        # Unexpected errors
        print(f"\n{'='*60}", file=sys.stderr)
        print(f"UNEXPECTED ERROR: {e}", file=sys.stderr)
        print(f"\nPlease report this issue with the above error message.", file=sys.stderr)
        print(f"{'='*60}\n", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()