import argparse
import json
import re
import os
import subprocess
import sys
import tempfile
from pathlib import Path
import shutil
from typing import Tuple, Dict, Optional, Any
from lessons import LESSONS

# --- Configuration ---

CONFIG_DIR = Path.home() / ".config" / "nimlings"
PROGRESS_FILE = CONFIG_DIR / "progress.json"
STATE_FILE = CONFIG_DIR / "state.json"

class Engine:
    def __init__(self):
        self.config_dir = CONFIG_DIR
        self.progress_file = PROGRESS_FILE
        self.state_file = STATE_FILE
        self.lessons = LESSONS
        self._ensure_config_dir()

    def _ensure_config_dir(self):
        self.config_dir.mkdir(parents=True, exist_ok=True)

    def check_nim_installed(self):
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

    def load_progress(self) -> set:
        """Loads the set of completed lesson IDs from the progress file."""
        if not self.progress_file.exists():
            return set()
        try:
            with open(self.progress_file, "r", encoding="utf-8") as f:
                return set(json.load(f))
        except (json.JSONDecodeError, IOError):
            return set()

    def save_progress(self, completed_ids: set):
        """Saves the set of completed lesson IDs."""
        try:
            with open(self.progress_file, "w", encoding="utf-8") as f:
                json.dump(list(completed_ids), f)
        except IOError:
            print(f"Fatal: Could not write progress to {self.progress_file}.")
            sys.exit(1)

    def load_state(self) -> dict:
        """Loads the user's last active lesson state."""
        if not self.state_file.exists():
            return {}
        try:
            with open(self.state_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return {}

    def save_state(self, lesson_id: str):
        """Saves the user's last active lesson state."""
        try:
            with open(self.state_file, "w", encoding="utf-8") as f:
                json.dump({"last_lesson": lesson_id}, f)
        except IOError:
            pass

    def reset_progress(self) -> bool:
        """Deletes progress and state files."""
        files_removed = False
        for f in [self.progress_file, self.state_file]:
            if f.exists():
                try:
                    f.unlink()
                    files_removed = True
                except IOError:
                    pass
        return files_removed

    def get_lesson_by_id(self, lesson_id: str) -> Optional[Dict[str, Any]]:
        """Finds a lesson by its ID."""
        for module in self.lessons:
            for lesson in module["lessons"]:
                if lesson["id"] == lesson_id:
                    return lesson
        return None

    def run_code(self, filepath: Path, args: list[str] | None = None, timeout: int = 5, project_files: dict[str, str] | None = None, compile_cmd: str = "c", project_root: Path | None = None, skip_run: bool = False, compiler_args: list[str] | None = None) -> subprocess.CompletedProcess:
        """
        Compiles and runs a Nim source file.
        
        If project_files is provided, it creates those files.
        If project_root is provided, files are created relative to it. Otherwise relative to filepath.parent.
        compile_cmd can be "c" (default) or "js".
        If skip_run is True, it just returns a success result without running anything.
        compiler_args are passed to the compiler (before filename).
        args are passed to the program (after filename).
        """
        # Setup project files if any
        if project_files:
            root = project_root if project_root else filepath.parent
            for filename, content in project_files.items():
                # Handle subdirectories in filenames
                file_path = root / filename
                file_path.parent.mkdir(parents=True, exist_ok=True)
                file_path.write_text(content, encoding="utf-8")

        if skip_run:
            return subprocess.CompletedProcess(args=[], returncode=0, stdout="", stderr="")

        cmd = ["nim", compile_cmd]
        if compile_cmd == "c":
            cmd.extend(["-r", "--threads:on", "--hints:off"])
        elif compile_cmd == "js":
            # For JS, we compile to a file and then run it with node if available, or just check compilation?
            # The original requirement implies running it.
            # Let's assume we run it with nodejs.
            cmd.extend(["-o:" + str(filepath.with_suffix(".js")), "--hints:off"])
        
        if compiler_args:
            cmd.extend(compiler_args)

        cmd.append(str(filepath.name))
        
        if args and compile_cmd == "c":
            cmd.extend(args)
        
        try:
            # If JS, we need two steps: compile, then run node
            if compile_cmd == "js":
                # 1. Compile
                comp_res = subprocess.run(
                    cmd,
                    cwd=filepath.parent,
                    capture_output=True,
                    text=True,
                    encoding='utf-8',
                    timeout=timeout
                )
                if comp_res.returncode != 0:
                    return comp_res
                
                # 2. Run with Node
                js_file = filepath.with_suffix(".js")
                if not js_file.exists():
                     return subprocess.CompletedProcess(args=cmd, returncode=1, stdout="", stderr="JS file not generated.")
                
                node_cmd = ["node", js_file.name]
                return subprocess.run(
                    node_cmd,
                    cwd=filepath.parent,
                    capture_output=True,
                    text=True,
                    encoding='utf-8',
                    timeout=timeout
                )

            # Standard C compilation + run
            return subprocess.run(
                cmd,
                cwd=filepath.parent,
                capture_output=True,
                text=True,
                encoding='utf-8',
                timeout=timeout
            )
        except subprocess.TimeoutExpired:
             return subprocess.CompletedProcess(
                args=cmd,
                returncode=124,
                stdout="",
                stderr="Error: Execution timed out. Infinite loop?"
            )

    def check_style(self, user_code: str) -> Optional[str]:
        """
        Checks if the code adheres to nimpretty style.
        Returns a warning message if not, or None if it's fine.
        """
        if not shutil.which("nimpretty"):
            return None # Skip if not installed

        with tempfile.TemporaryDirectory() as tmp_dir:
            p = Path(tmp_dir) / "style_check.nim"
            p.write_text(user_code, encoding="utf-8")
            
            try:
                subprocess.run(
                    ["nimpretty", str(p)],
                    check=True,
                    capture_output=True,
                    timeout=5
                )
                formatted = p.read_text(encoding="utf-8")
                if formatted != user_code:
                    import difflib
                    
                    # Check if difference is only whitespace/newlines
                    user_stripped = user_code.strip()
                    formatted_stripped = formatted.strip()
                    only_whitespace = (user_stripped == formatted_stripped)
                    
                    diff = difflib.unified_diff(
                        user_code.splitlines(keepends=True),
                        formatted.splitlines(keepends=True),
                        fromfile='Your Code',
                        tofile='Professional Style',
                    )
                    
                    diff_lines = []
                    for line in diff:
                        # Show trailing spaces explicitly
                        display_line = line.rstrip('\n').replace(' \n', '·\n').replace('\t', '→')
                        # Add marker for lines with trailing whitespace
                        if line.startswith('-') or line.startswith('+'):
                            original_line = line.rstrip('\n')
                            if original_line.endswith(' '):
                                display_line = original_line.rstrip() + '·'
                        diff_lines.append(display_line)
                    
                    diff_text = '\n'.join(diff_lines)
                    
                    # Add explanation for whitespace-only changes
                    explanation = ""
                    if only_whitespace:
                        if not user_code.endswith('\n') and formatted.endswith('\n'):
                            explanation = "\n💡 Tip: Files should end with a newline character."
                        elif user_code.endswith(' ') or user_code.endswith('\t'):
                            explanation = "\n💡 Tip: Lines shouldn't have trailing whitespace. (· = space)"
                        else:
                            explanation = "\n💡 Tip: Whitespace/formatting difference. (· = space, → = tab)"
                    
                    return f"Style Warning: Your code isn't formatted according to 'nimpretty'.\nHere is how to improve it:\n\n```diff\n{diff_text}\n```{explanation}"
            except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
                pass # Ignore style check failures (syntax errors caught elsewhere)
        return None

    def validate_lesson(self, lesson: dict, user_code: str, result: subprocess.CompletedProcess) -> Tuple[bool, str]:
        """
        Checks the user's solution.
        Returns (success, feedback_message).
        """
        if result.returncode != 0:
            msg = f"\n--- COMPILE ERROR ---\nYou wrote:\n---\n{user_code}\n---\nYeah, that didn't work. The compiler spit this back at you:\n{result.stderr}\n\n            HINT: {lesson.get('hint', 'No hint available.')}"
            return False, msg

        if lesson["validation"](user_code, result):
            msg = "\nAlright, that works. Don't get cocky."
            style_warn = self.check_style(user_code)
            if style_warn:
                msg += f"\n\n{style_warn}"
            return True, msg

        msg = f"\n--- LOGIC ERROR ---\nYou wrote:\n---\n{user_code}\n---\nIt compiled, but it's wrong. Your code produced this output:\n```\n{result.stdout.strip()}\n```\n\nThat's not what was asked for. Try again."
        return False, msg

    def get_editor(self) -> str:
        editor = os.environ.get("EDITOR")
        if editor:
            return editor
        if shutil.which("vim"):
            return "vim"
        return "nano"
