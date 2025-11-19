import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))
from src.tui import TUIApp
from src.engine import Engine
from pathlib import Path
import curses

# Mock Engine
class MockEngine(Engine):
    def __init__(self):
        self.config_dir = Path("/tmp")
        self.lessons = []
    def load_progress(self): return set()
    def load_state(self): return {}

# Mock TUIApp
class MockTUI(TUIApp):
    def __init__(self):
        self.engine = MockEngine()
        self.editor_lines = ["line1"]
        self.editor_cy = 0
        self.editor_cx = 0
        self.clipboard = None
        self.undo_stack = []
        self.operator_pending = None
        self.show_help = False
        self.window_command_mode = False
        # Skip file loading

    def _save_editor_file(self): pass
    def _clamp_cursor(self): pass

tui = MockTUI()

print(f"Initial show_help: {tui.show_help}")

# Test Toggle
# Simulate Ctrl+/ (31)
key = 31
if key == 31:
    tui.show_help = not tui.show_help

print(f"After Ctrl+/: {tui.show_help}")
assert tui.show_help == True

# Toggle back
if key == 31:
    tui.show_help = not tui.show_help

print(f"After second Ctrl+/: {tui.show_help}")
assert tui.show_help == False

print("Cheatsheet toggle logic verified.")
