from engine import Engine
from pathlib import Path
import shutil

# Mock config dir
class MockEngine(Engine):
    def __init__(self):
        self.config_dir = Path("/tmp")
        self.lessons = []

e = MockEngine()
# Case 1: Trailing newline difference
code = 'proc ugly(x:int)=echo x' # No newline
warn = e.check_style(code)
print(f"--- Case 1: Trailing Newline ---\n{warn}\n")

# Case 2: Whitespace difference
code2 = 'proc ugly(x: int) = echo x ' # Trailing space
warn2 = e.check_style(code2)
print(f"--- Case 2: Whitespace ---\n{warn2}\n")
