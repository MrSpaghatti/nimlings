import curses
import tempfile
from pathlib import Path
import subprocess
from engine import Engine
from lessons import LESSONS

class TUIApp:
    def __init__(self, engine):
        self.engine = engine
        self.stdscr = None
        self.progress = self.engine.load_progress()
        self.flat_lessons = [lesson for module in LESSONS for lesson in module["lessons"]]
        self.current_lesson_idx = 0
        self.active_view = "tree" # "tree" or "content"
        self.scroll_offset = 0
        self.content_scroll_offset = 0
        self.output_buffer = []

    def run(self):
        curses.wrapper(self._main_loop)

    def _main_loop(self, stdscr):
        self.stdscr = stdscr
        curses.curs_set(0)
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_GREEN, -1) # Completed
        curses.init_pair(2, curses.COLOR_CYAN, -1)  # Selected
        curses.init_pair(3, curses.COLOR_RED, -1)   # Error
        curses.init_pair(4, curses.COLOR_YELLOW, -1) # Warning/Hint

        # Load state
        state = self.engine.load_state()
        last_id = state.get("last_lesson")
        if last_id:
             idx = next((i for i, l in enumerate(self.flat_lessons) if l["id"] == last_id), -1)
             if idx != -1:
                 self.current_lesson_idx = idx

        while True:
            self.stdscr.clear()
            h, w = self.stdscr.getmaxyx()

            # Draw Layout
            # Tree: Left 30%
            tree_w = int(w * 0.3)
            self._draw_tree(h, tree_w)
            
            # Content: Right Top (split height)
            # Output: Right Bottom
            content_h = int(h * 0.6)
            self._draw_content(0, tree_w, content_h, w - tree_w)
            self._draw_output(content_h, tree_w, h - content_h, w - tree_w)

            self.stdscr.refresh()

            key = self.stdscr.getch()

            if key == ord('q'):
                break
            elif key == curses.KEY_UP:
                if self.active_view == "tree":
                    self.current_lesson_idx = max(0, self.current_lesson_idx - 1)
                    # Auto-scroll tree logic if needed
                elif self.active_view == "content":
                     self.content_scroll_offset = max(0, self.content_scroll_offset - 1)
            elif key == curses.KEY_DOWN:
                if self.active_view == "tree":
                    self.current_lesson_idx = min(len(self.flat_lessons) - 1, self.current_lesson_idx + 1)
                elif self.active_view == "content":
                    self.content_scroll_offset += 1
            elif key == ord('\t'):
                self.active_view = "content" if self.active_view == "tree" else "tree"
            elif key == ord('e'): # Edit
                self._open_editor()
            elif key == ord('r'): # Run
                self._run_check()
            elif key == ord('h'): # Hint
                self._show_hint()
            elif key == ord('s'): # Solution
                self._show_solution()
            elif key in [curses.KEY_ENTER, 10, 13]:
                 # Selecting a lesson in tree resets content scroll
                 self.active_view = "content"
                 self.content_scroll_offset = 0
                 # Save state
                 current_id = self.flat_lessons[self.current_lesson_idx]["id"]
                 self.engine.save_state(current_id)

    def _draw_tree(self, h, w):
        win = curses.newwin(h, w, 0, 0)
        win.box()
        win.addstr(0, 2, " Curriculum ")
        
        max_items = h - 2
        start_idx = max(0, self.current_lesson_idx - (max_items // 2))
        end_idx = min(len(self.flat_lessons), start_idx + max_items)

        for i in range(start_idx, end_idx):
            lesson = self.flat_lessons[i]
            y = i - start_idx + 1
            marker = "[x]" if lesson["id"] in self.progress else "[ ]"
            
            name = f"{marker} {lesson['id']}: {lesson['name']}"
            if len(name) > w - 4:
                name = name[:w-4] + "..."
            
            attr = curses.A_NORMAL
            if i == self.current_lesson_idx:
                attr = curses.color_pair(2) | curses.A_BOLD
                if self.active_view == "tree":
                    attr |= curses.A_REVERSE
            elif lesson["id"] in self.progress:
                attr = curses.color_pair(1)

            win.addstr(y, 2, name, attr)
        
        win.refresh()

    def _draw_content(self, y, x, h, w):
        win = curses.newwin(h, w, y, x)
        win.box()
        win.addstr(0, 2, " Lesson ")

        lesson = self.flat_lessons[self.current_lesson_idx]
        lines = []
        lines.append(f"ID: {lesson['id']}")
        lines.append(f"Name: {lesson['name']}")
        lines.append("")
        lines.append("--- Concept ---")
        lines.extend(self._wrap_text(lesson['concept'], w - 4))
        lines.append("")
        lines.append("--- Task ---")
        lines.extend(self._wrap_text(lesson['task'], w - 4))

        for i, line in enumerate(lines[self.content_scroll_offset:]):
            if i + 1 >= h - 1: break
            win.addstr(i + 1, 2, line)
        
        win.refresh()

    def _draw_output(self, y, x, h, w):
        win = curses.newwin(h, w, y, x)
        win.box()
        win.addstr(0, 2, " Output (r: Run, e: Edit, q: Quit) ")
        
        for i, line in enumerate(self.output_buffer):
             if i + 1 >= h - 1: break
             # Rudimentary ansi filtering or just printing text
             # Ideally strip ANSI codes
             clean_line = line # TODO: strip ansi
             if len(clean_line) > w - 4:
                 clean_line = clean_line[:w-4]
             win.addstr(i + 1, 2, clean_line)

        win.refresh()

    def _wrap_text(self, text, width):
        lines = []
        for para in text.split('\n'):
            while len(para) > width:
                split_at = para[:width].rfind(' ')
                if split_at == -1: split_at = width
                lines.append(para[:split_at])
                para = para[split_at:].lstrip()
            lines.append(para)
        return lines

    def _open_editor(self):
        draft_file = self.engine.config_dir / "draft.nim"
        if not draft_file.exists():
             draft_file.write_text("", encoding="utf-8")
        
        editor = self.engine.get_editor()
        
        curses.endwin()
        subprocess.run([editor, str(draft_file)])
        self.stdscr.refresh() # Restore curses
    
    def _run_check(self):
        lesson = self.flat_lessons[self.current_lesson_idx]
        if not lesson.get("validation"):
            self.output_buffer = ["Just press Enter on 'Intro' lessons. (Actually, logic handled differently but ok)."]
            # Auto-complete intro lessons
            self.progress.add(lesson["id"])
            self.engine.save_progress(self.progress)
            self.output_buffer = ["Lesson Complete!"]
            return

        draft_file = self.engine.config_dir / "draft.nim"
        if not draft_file.exists():
            self.output_buffer = ["No code written yet. Press 'e' to edit."]
            return
        
        user_code = draft_file.read_text(encoding="utf-8")
        
        self.output_buffer = ["Compiling..."]
        self._draw_output(0,0,0,0) # Force refresh? No, main loop handles it next frame.
        
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = Path(tmp_dir) / "solution.nim"
            tmp_path.write_text(user_code, encoding="utf-8")
            
            result = self.engine.run_code(tmp_path, lesson.get("args"))
            
            success, msg = self.engine.validate_lesson(lesson, user_code, result)
            
            self.output_buffer = msg.split('\n')
            
            if success:
                self.progress.add(lesson["id"])
                self.engine.save_progress(self.progress)

    def _show_hint(self):
        lesson = self.flat_lessons[self.current_lesson_idx]
        hint = lesson.get("hint", "No hint available.")
        self.output_buffer = ["--- HINT ---", hint]

    def _show_solution(self):
        lesson = self.flat_lessons[self.current_lesson_idx]
        sol = lesson.get("solution", "No solution available.")
        self.output_buffer = ["--- SOLUTION ---"] + sol.split('\n')
