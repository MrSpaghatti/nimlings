import curses
import re
import tempfile
from pathlib import Path
import subprocess
from engine import Engine
class TUIApp:
    def __init__(self, engine):
        self.engine = engine
        self.stdscr = None
        self.progress = self.engine.load_progress()
        self.flat_lessons = [lesson for module in self.engine.lessons for lesson in module["lessons"]]
        self.current_lesson_idx = 0
        self.active_view = "tree" # "tree" or "content"
        self.scroll_offset = 0
        self.content_scroll_offset = 0
        self.output_buffer = []
        
        # Editor State
        self.editor_lines = [""]
        self.editor_cy = 0
        self.editor_cx = 0
        self.editor_scroll = 0
        self.editor_mode = "NORMAL" # NORMAL, INSERT, VISUAL
        self.visual_start = None # (y, x) tuple
        self.editor_message = "" # For status bar
        self._load_editor_file()

    def _load_editor_file(self):
        draft_file = self.engine.config_dir / "draft.nim"
        if draft_file.exists():
            content = draft_file.read_text(encoding="utf-8")
            self.editor_lines = content.splitlines()
        if not self.editor_lines:
            self.editor_lines = [""]

    def _save_editor_file(self):
        draft_file = self.engine.config_dir / "draft.nim"
        content = "\n".join(self.editor_lines)
        draft_file.write_text(content, encoding="utf-8")

    def _clamp_cursor(self):
        self.editor_cy = max(0, min(len(self.editor_lines) - 1, self.editor_cy))
        line_len = len(self.editor_lines[self.editor_cy])
        if self.editor_mode == "INSERT":
             self.editor_cx = max(0, min(line_len, self.editor_cx))
        else:
             # In Normal/Visual, cursor can't go past last char unless line is empty
             self.editor_cx = max(0, min(line_len - 1 if line_len > 0 else 0, self.editor_cx))

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
        curses.init_pair(5, curses.COLOR_WHITE, curses.COLOR_BLUE) # Visual Selection

        # Load state
        state = self.engine.load_state()
        last_id = state.get("last_lesson")
        if last_id:
             idx = next((i for i, l in enumerate(self.flat_lessons) if l["id"] == last_id), -1)
             if idx != -1:
                 self.current_lesson_idx = idx
        
        # Track cursor visibility to avoid redundant calls
        self.cursor_visible = False
        curses.curs_set(0)

        while True:
            # Removed self.stdscr.clear() and refresh() to reduce flicker.
            # We use subwindows that cover the screen and noutrefresh + doupdate.
            h, w = self.stdscr.getmaxyx()

            # Layout Calculation
            tree_w = int(w * 0.3)
            right_w = w - tree_w
            
            content_h = int(h * 0.35)
            editor_h = int(h * 0.45)
            output_h = h - content_h - editor_h

            # Draw Windows (using noutrefresh)
            # Order: Tree, Content, Output, Editor (so editor cursor placement is last)
            self._draw_tree(h, tree_w)
            self._draw_content(0, tree_w, content_h, right_w)
            self._draw_output(content_h + editor_h, tree_w, output_h, right_w)
            self._draw_editor(content_h, tree_w, editor_h, right_w)

            # Cursor visibility
            target_cursor = (self.active_view == "editor")
            if target_cursor != self.cursor_visible:
                curses.curs_set(1 if target_cursor else 0)
                self.cursor_visible = target_cursor

            # Finalize screen update
            curses.doupdate()

            key = self.stdscr.getch()

            # Input Routing
            if self.active_view == "editor":
                if key == ord('\t') and self.editor_mode == "NORMAL": # Exit editor only in Normal
                    self.active_view = "tree"
                else:
                    self._handle_editor_input(key)
            else:
                # Navigation Mode
                if key == ord('q'): # Quit when not in editor
                    break
                
                # Vertical Navigation (Arrow Keys + Vim bindings)
                elif key in [curses.KEY_UP, ord('k')]:
                    if self.active_view == "tree":
                        self.current_lesson_idx = max(0, self.current_lesson_idx - 1)
                    elif self.active_view == "content":
                        self.content_scroll_offset = max(0, self.content_scroll_offset - 1)
                
                elif key in [curses.KEY_DOWN, ord('j')]:
                    if self.active_view == "tree":
                        self.current_lesson_idx = min(len(self.flat_lessons) - 1, self.current_lesson_idx + 1)
                    elif self.active_view == "content":
                        self.content_scroll_offset += 1
                
                # Page Navigation
                elif key == curses.KEY_PPAGE: # Page Up
                    if self.active_view == "tree":
                        self.current_lesson_idx = max(0, self.current_lesson_idx - 10)
                    elif self.active_view == "content":
                        self.content_scroll_offset = max(0, self.content_scroll_offset - 10)
                
                elif key == curses.KEY_NPAGE: # Page Down
                    if self.active_view == "tree":
                        self.current_lesson_idx = min(len(self.flat_lessons) - 1, self.current_lesson_idx + 10)
                    elif self.active_view == "content":
                         self.content_scroll_offset += 10
                
                # Jump Navigation
                elif key == ord('g'): # Top
                    if self.active_view == "tree":
                        self.current_lesson_idx = 0
                    elif self.active_view == "content":
                        self.content_scroll_offset = 0
                
                elif key == ord('G'): # Bottom
                    if self.active_view == "tree":
                        self.current_lesson_idx = len(self.flat_lessons) - 1
                    # For content, exact bottom is hard to calc without wrapping, so we skip or just jump 'far'
                    # Let's skip for content to avoid blank screens.

                elif key == ord('\t'):
                    # Cycle: Tree -> Content -> Editor -> Tree
                    if self.active_view == "tree": self.active_view = "content"
                    elif self.active_view == "content": self.active_view = "editor"
                    else: self.active_view = "tree"
                elif key == ord('e'): # Focus Editor
                    self.active_view = "editor"
                elif key == ord('r'): # Run
                    self._run_check()
                elif key == ord('h'): # Hint
                    self._show_hint()
                elif key == ord('s'): # Solution
                    self._show_solution()
                elif key in [curses.KEY_ENTER, 10, 13]:
                    if self.active_view == "tree":
                        self.active_view = "content"
                        self.content_scroll_offset = 0
                        current_id = self.flat_lessons[self.current_lesson_idx]["id"]
                        self.engine.save_state(current_id)

    def _draw_tree(self, h, w):
        win = curses.newwin(h, w, 0, 0)
        win.erase() # Clear window buffer
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
        
        win.noutrefresh()

    def _draw_content(self, y, x, h, w):
        win = curses.newwin(h, w, y, x)
        win.erase()
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
        
        win.noutrefresh()

    def _draw_output(self, y, x, h, w):
        win = curses.newwin(h, w, y, x)
        win.erase()
        win.box()
        win.addstr(0, 2, " Output (r: Run, e: Edit, q: Quit) ")
        
        for i, line in enumerate(self.output_buffer):
             if i + 1 >= h - 1: break
             clean_line = self._strip_ansi(line)
             if len(clean_line) > w - 4:
                 clean_line = clean_line[:w-4]
             win.addstr(i + 1, 2, clean_line)

        win.noutrefresh()

    def _draw_editor(self, y, x, h, w):
        win = curses.newwin(h, w, y, x)
        win.erase()
        win.box()
        
        title = f" Editor [{self.editor_mode}] "
        if self.active_view == "editor":
             win.addstr(0, 2, title, curses.A_BOLD | curses.color_pair(2))
        else:
             win.addstr(0, 2, title)

        # Status Bar (Bottom line)
        status = f" {self.editor_mode} | {self.editor_cy + 1}:{self.editor_cx + 1} | {self.editor_message}"
        if len(status) > w - 2: status = status[:w-2]
        win.addstr(h - 1, 1, status, curses.A_REVERSE)

        # Calculate render area
        # Leave 1 line for border top, 1 for border bottom (status)
        view_h = h - 2
        
        # Adjust scroll
        if self.editor_cy < self.editor_scroll:
            self.editor_scroll = self.editor_cy
        elif self.editor_cy >= self.editor_scroll + view_h:
            self.editor_scroll = self.editor_cy - view_h + 1

        # Determine visual selection range
        sel_start = None
        sel_end = None
        if self.editor_mode == "VISUAL" and self.visual_start:
            p1 = self.visual_start
            p2 = (self.editor_cy, self.editor_cx)
            if p1 > p2: p1, p2 = p2, p1
            sel_start = p1
            sel_end = p2

        for i in range(view_h):
            line_idx = self.editor_scroll + i
            if line_idx >= len(self.editor_lines):
                break
            
            line_content = self.editor_lines[line_idx]
            # Draw line char by char for highlighting
            # (Simplified: chunking would be faster but Python loops are slow anyway)
            
            display_str = line_content
            if len(display_str) > w - 3:
                display_str = display_str[:w-3] + "$"
            
            # Basic print first
            win.addstr(i + 1, 2, display_str)

            # Apply highlight if needed
            if sel_start and sel_end:
                # Check if this line is involved
                if sel_start[0] <= line_idx <= sel_end[0]:
                    start_x = 0
                    end_x = len(display_str)
                    
                    if line_idx == sel_start[0]:
                        start_x = sel_start[1]
                    if line_idx == sel_end[0]:
                        end_x = sel_end[1] + 1 # inclusive
                    
                    # Clamp to display
                    start_x = max(0, min(start_x, len(display_str)))
                    end_x = max(0, min(end_x, len(display_str)))
                    
                    if start_x < end_x:
                        win.addstr(i + 1, 2 + start_x, display_str[start_x:end_x], curses.color_pair(5))

        # Draw cursor if active
        if self.active_view == "editor":
            screen_y = self.editor_cy - self.editor_scroll + 1
            screen_x = self.editor_cx + 2
            screen_x = min(screen_x, w - 2)
            win.move(screen_y, screen_x)

        win.noutrefresh()

    def _handle_editor_input(self, key):
        if self.editor_mode == "NORMAL":
            self._handle_normal_input(key)
        elif self.editor_mode == "INSERT":
            self._handle_insert_input(key)
        elif self.editor_mode == "VISUAL":
            self._handle_visual_input(key)

    def _handle_normal_input(self, key):
        self.editor_message = ""
        # Mode Switch
        if key == ord('i'):
            self.editor_mode = "INSERT"
            self.editor_message = "-- INSERT --"
        elif key == ord('v'):
            self.editor_mode = "VISUAL"
            self.visual_start = (self.editor_cy, self.editor_cx)
            self.editor_message = "-- VISUAL --"
        
        # Navigation (hjkl)
        elif key == ord('h') or key == curses.KEY_LEFT:
            self.editor_cx = max(0, self.editor_cx - 1)
        elif key == ord('j') or key == curses.KEY_DOWN:
             if self.editor_cy < len(self.editor_lines) - 1:
                self.editor_cy += 1
        elif key == ord('k') or key == curses.KEY_UP:
             self.editor_cy = max(0, self.editor_cy - 1)
        elif key == ord('l') or key == curses.KEY_RIGHT:
             self.editor_cx += 1

        # Actions
        elif key == ord('x'): # Delete char
            line = self.editor_lines[self.editor_cy]
            if self.editor_cx < len(line):
                self.editor_lines[self.editor_cy] = line[:self.editor_cx] + line[self.editor_cx+1:]
        
        elif key == ord('d'): # Simplistic dd (delete line) - wait for second d?
             # For simplicity, let's just make 'd' delete current line for now or require 'dd'
             # Implementing full operator pending state is complex. 
             # Let's do 'D' (shift+d) deletes line, or just 'd' deletes line.
             # Or checking previous key... let's keep it simple: 'x' deletes char, 'd' deletes line.
             if len(self.editor_lines) > 1:
                 self.editor_lines.pop(self.editor_cy)
                 if self.editor_cy >= len(self.editor_lines):
                     self.editor_cy = len(self.editor_lines) - 1
             else:
                 self.editor_lines[0] = ""

        elif key == ord('p'): # Paste (very basic placeholder)
            self.editor_message = "Paste not impl"

        elif key == ord('u'): # Undo
            self.editor_message = "Undo not impl"

        elif key == ord('r'): # Run
             self._run_check()
             self.active_view = "content" # Exit focus
             self.editor_mode = "NORMAL"

        self._clamp_cursor()

    def _handle_insert_input(self, key):
        self.editor_message = "-- INSERT --"
        if key == 27: # ESC
            self.editor_mode = "NORMAL"
            self.editor_message = ""
            # Move cursor back one step if possible
            self.editor_cx = max(0, self.editor_cx - 1)
            return

        # Standard typing
        if key in [curses.KEY_BACKSPACE, 127, 8]:
            if self.editor_cx > 0:
                line = self.editor_lines[self.editor_cy]
                self.editor_lines[self.editor_cy] = line[:self.editor_cx-1] + line[self.editor_cx:]
                self.editor_cx -= 1
            elif self.editor_cy > 0:
                # Merge
                curr = self.editor_lines.pop(self.editor_cy)
                prev_len = len(self.editor_lines[self.editor_cy - 1])
                self.editor_lines[self.editor_cy - 1] += curr
                self.editor_cy -= 1
                self.editor_cx = prev_len
        
        elif key in [curses.KEY_ENTER, 10, 13]:
            line = self.editor_lines[self.editor_cy]
            rest = line[self.editor_cx:]
            self.editor_lines[self.editor_cy] = line[:self.editor_cx]
            self.editor_lines.insert(self.editor_cy + 1, rest)
            self.editor_cy += 1
            self.editor_cx = 0
        
        elif 32 <= key <= 126:
            char = chr(key)
            line = self.editor_lines[self.editor_cy]
            self.editor_lines[self.editor_cy] = line[:self.editor_cx] + char + line[self.editor_cx:]
            self.editor_cx += 1
        
        # Navigation in Insert
        elif key == curses.KEY_LEFT: self.editor_cx = max(0, self.editor_cx - 1)
        elif key == curses.KEY_RIGHT: self.editor_cx += 1
        elif key == curses.KEY_UP: self.editor_cy = max(0, self.editor_cy - 1)
        elif key == curses.KEY_DOWN: 
             if self.editor_cy < len(self.editor_lines) - 1: self.editor_cy += 1

        self._clamp_cursor()

    def _handle_visual_input(self, key):
        self.editor_message = "-- VISUAL --"
        if key == 27: # ESC
            self.editor_mode = "NORMAL"
            self.visual_start = None
            self.editor_message = ""
            return
        
        # Navigation expands selection
        if key == ord('h') or key == curses.KEY_LEFT: self.editor_cx = max(0, self.editor_cx - 1)
        elif key == ord('l') or key == curses.KEY_RIGHT: self.editor_cx += 1
        elif key == ord('j') or key == curses.KEY_DOWN: 
             if self.editor_cy < len(self.editor_lines) - 1: self.editor_cy += 1
        elif key == ord('k') or key == curses.KEY_UP: self.editor_cy = max(0, self.editor_cy - 1)

        # Operations
        elif key == ord('y'): # Yank
             # Capture selection
             self.editor_mode = "NORMAL"
             self.visual_start = None
             self.editor_message = "Yanked (mock)"
        
        elif key == ord('d') or key == ord('x'): # Delete selection
             # Delete selection logic (simplified: just delete lines for now or stub)
             self.editor_mode = "NORMAL"
             self.visual_start = None
             self.editor_message = "Deleted (mock)"

        self._clamp_cursor()
            
    def _strip_ansi(self, text):
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        return ansi_escape.sub('', text)

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

    def _run_check(self):
        self._save_editor_file() # Save first

        lesson = self.flat_lessons[self.current_lesson_idx]
        if not lesson.get("validation"):
            self.output_buffer = ["Just press Enter on 'Intro' lessons. (Actually, logic handled differently but ok)."]
            # Auto-complete intro lessons
            self.progress.add(lesson["id"])
            self.engine.save_progress(self.progress)
            self.output_buffer = ["Lesson Complete!"]
            return

        draft_file = self.engine.config_dir / "draft.nim"
        # File is ensured by _save_editor_file
        
        user_code = draft_file.read_text(encoding="utf-8")
        
        self.output_buffer = ["Compiling..."]
        # Force immediate refresh of output window to show "Compiling..."? 
        # In this loop structure, it won't show until next frame.
        # To make it show immediately, we'd need to redraw output and refresh.
        # But let's keep it simple.
        
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
