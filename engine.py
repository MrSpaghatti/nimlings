import argparse
import json
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

    def run_code(self, filepath: Path, args: list[str] | None = None, timeout: int = 5) -> subprocess.CompletedProcess:
        """Compiles and runs a Nim source file."""
        cmd = ["nim", "c", "-r", "--threads:on", "--hints:off", str(filepath.name)]
        if args:
            cmd.extend(args)
        
        try:
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

    def validate_lesson(self, lesson: dict, user_code: str, result: subprocess.CompletedProcess) -> Tuple[bool, str]:
        """
        Checks the user's solution.
        Returns (success, feedback_message).
        """
        if result.returncode != 0:
            msg = f"\n--- COMPILE ERROR ---\nYou wrote:\n---\n{user_code}\n---\nYeah, that didn't work. The compiler spit this back at you:\n{result.stderr}\n\n            HINT: {lesson.get('hint', 'No hint available.')}"
            return False, msg

        if lesson["validation"](user_code, result):
            return True, "\nAlright, that works. Don't get cocky."

        msg = f"\n--- LOGIC ERROR ---\nYou wrote:\n---\n{user_code}\n---\nIt compiled, but it's wrong. Your code produced this output:\n```\n{result.stdout.strip()}\n```\n\nThat's not what was asked for. Try again."
        return False, msg

    def get_editor(self) -> str:
        editor = os.environ.get("EDITOR")
        if editor:
            return editor
        if shutil.which("vim"):
            return "vim"
        return "nano"
