import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))
from src.engine import Engine
from pathlib import Path
import shutil

# Mock config dir
class MockEngine(Engine):
    def __init__(self):
        self.config_dir = Path("/tmp")
        self.lessons = []

e = MockEngine()
code = "proc ugly(x:int)=echo x"
warn = e.check_style(code)
print(warn)
