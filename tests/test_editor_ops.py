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

# Mock TUIApp to avoid curses init
class MockTUI(TUIApp):
    def __init__(self):
        self.engine = MockEngine()
        self.editor_lines = ["line1", "line2", "line3"]
        self.editor_cy = 0
        self.editor_cx = 0
        self.clipboard = None
        self.undo_stack = []
        self.operator_pending = None
        self.editor_mode = "NORMAL"
        self.window_command_mode = False
        # Skip file loading

    def _save_editor_file(self): pass
    def _clamp_cursor(self):
        self.editor_cy = max(0, min(len(self.editor_lines) - 1, self.editor_cy))

tui = MockTUI()

print(f"Initial: {tui.editor_lines}")

# Test dd
print("--- Testing dd ---")
tui._handle_normal_input(ord('d'))
tui._handle_normal_input(ord('d'))
print(f"After dd: {tui.editor_lines}")
assert tui.editor_lines == ["line2", "line3"]
assert tui.clipboard == ["line1"]

# Test u
print("--- Testing u ---")
tui._handle_normal_input(ord('u'))
print(f"After u: {tui.editor_lines}")
assert tui.editor_lines == ["line1", "line2", "line3"]

# Test yy
print("--- Testing yy ---")
tui._handle_normal_input(ord('y'))
tui._handle_normal_input(ord('y'))
print(f"Clipboard after yy: {tui.clipboard}")
assert tui.clipboard == ["line1"]

# Test p
print("--- Testing p ---")
tui._handle_normal_input(ord('p'))
print(f"After p: {tui.editor_lines}")
assert tui.editor_lines == ["line1", "line1", "line2", "line3"]

# Test Undo p
print("--- Testing Undo p ---")
tui._handle_normal_input(ord('u'))
print(f"After undo p: {tui.editor_lines}")
assert tui.editor_lines == ["line1", "line2", "line3"]

print("All tests passed!")
