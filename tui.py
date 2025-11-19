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
        self.output_scroll_offset = 0
        self.output_buffer = []
        
        # Editor State
        self.editor_lines = [""]
        self.editor_cy = 0
        self.editor_cx = 0
        self.editor_scroll = 0
        self.editor_mode = "NORMAL" # NORMAL, INSERT, VISUAL
        self.visual_start = None # (y, x) tuple
        self.editor_message = "" # For status bar
        self.window_command_mode = False # For Ctrl+w handling
        self.clipboard = None # Content of yank/delete
        self.undo_stack = [] # List of (lines, cy, cx) tuples
        self.operator_pending = None # 'd', 'y', etc.
        self.show_help = False # Toggle for cheatsheet
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

    def _save_undo_state(self):
        # Deep copy lines to avoid reference issues
        self.undo_stack.append((list(self.editor_lines), self.editor_cy, self.editor_cx))
        # Limit stack size
        if len(self.undo_stack) > 50:
            self.undo_stack.pop(0)

    def _move_word_forward(self):
        # Simple implementation: skip current word, then skip whitespace
        line = self.editor_lines[self.editor_cy]
        
        # If at end of line, move to next line
        if self.editor_cx >= len(line):
            if self.editor_cy < len(self.editor_lines) - 1:
                self.editor_cy += 1
                self.editor_cx = 0
                # Skip leading whitespace on new line
                line = self.editor_lines[self.editor_cy]
                while self.editor_cx < len(line) and line[self.editor_cx].isspace():
                    self.editor_cx += 1
            return

        # Helper to check if char is part of a "word" (alphanumeric + underscore)
        def is_word_char(c): return c.isalnum() or c == '_'

        # If currently on a word char, skip to end of word
        if is_word_char(line[self.editor_cx]):
            while self.editor_cx < len(line) and is_word_char(line[self.editor_cx]):
                self.editor_cx += 1
        # If currently on non-word char (punctuation), skip run of punctuation
        elif not line[self.editor_cx].isspace():
             while self.editor_cx < len(line) and not is_word_char(line[self.editor_cx]) and not line[self.editor_cx].isspace():
                self.editor_cx += 1
        
        # Skip whitespace
        while self.editor_cx < len(line) and line[self.editor_cx].isspace():
            self.editor_cx += 1
        
        # If we hit end of line, we are done (next 'w' will handle wrap)

    def _move_word_backward(self):
        line = self.editor_lines[self.editor_cy]
        
        # If at start of line, move to end of prev line
        if self.editor_cx == 0:
            if self.editor_cy > 0:
                self.editor_cy -= 1
                self.editor_cx = len(self.editor_lines[self.editor_cy])
                # Don't skip anything, just land at end. Next 'b' will handle it.
            return

        self.editor_cx -= 1
        
        # Skip whitespace backwards
        while self.editor_cx > 0 and line[self.editor_cx].isspace():
            self.editor_cx -= 1

        def is_word_char(c): return c.isalnum() or c == '_'
        
        # Determine type of "word" we are on
        start_type_is_word = is_word_char(line[self.editor_cx])
        
        # Move back to start of this block
        while self.editor_cx > 0:
            prev_char = line[self.editor_cx - 1]
            if is_word_char(prev_char) != start_type_is_word or prev_char.isspace():
                break
            self.editor_cx -= 1

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
        # Reduce ESC delay for faster mode switching
        curses.set_escdelay(25)
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

        # Initial clear and refresh to ensure screen is ready
        self.stdscr.clear()
        self.stdscr.refresh()

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
            
            if key == curses.KEY_RESIZE:
                # Curses handles the signal, but we need to re-layout and redraw
                # The loop will handle redraw at the top
                curses.update_lines_cols() # Ensure curses knows about new size
                continue

            # Toggle Help (Ctrl+/ usually sends 31 or 26 or 37 depending on term, let's try 31 and '_')
            # Some terminals send `^_` (31) for Ctrl+/
            if key == 31 or key == ord('_') or key == 263: # 263 is sometimes backspace but let's be safe
                 # Actually, let's just check for the common ones.
                 pass 
            
            # Better: Handle it in input routing or global? Global seems best.
            # Let's try to catch it.
            if key == 31: # Unit Separator (Ctrl+/)
                self.show_help = not self.show_help
                continue
            
            # Window Command Mode (Ctrl+w prefix)
            if self.window_command_mode:
                self.window_command_mode = False
                if key in [ord('h'), curses.KEY_LEFT]:
                    self.active_view = "tree"
                elif key in [ord('l'), curses.KEY_RIGHT]:
                    self.active_view = "editor"
                elif key in [ord('j'), curses.KEY_DOWN]:
                    # Cycle down: Content -> Editor -> Output
                    if self.active_view == "content": self.active_view = "editor"
                    elif self.active_view == "editor": self.active_view = "output"
                elif key in [ord('k'), curses.KEY_UP]:
                    # Cycle up: Output -> Editor -> Content
                    if self.active_view == "output": self.active_view = "editor"
                    elif self.active_view == "editor": self.active_view = "content"
                continue

            if key == 23: # Ctrl+w
                self.window_command_mode = True
                continue

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
                    elif self.active_view == "output":
                        self.output_scroll_offset = max(0, self.output_scroll_offset - 1)
                
                elif key in [curses.KEY_DOWN, ord('j')]:
                    if self.active_view == "tree":
                        self.current_lesson_idx = min(len(self.flat_lessons) - 1, self.current_lesson_idx + 1)
                    elif self.active_view == "content":
                        self.content_scroll_offset += 1
                    elif self.active_view == "output":
                        self.output_scroll_offset += 1
                
                # Page Navigation
                elif key == curses.KEY_PPAGE: # Page Up
                    if self.active_view == "tree":
                        self.current_lesson_idx = max(0, self.current_lesson_idx - 10)
                    elif self.active_view == "content":
                        self.content_scroll_offset = max(0, self.content_scroll_offset - 10)
                    elif self.active_view == "output":
                        self.output_scroll_offset = max(0, self.output_scroll_offset - 10)
                
                elif key == curses.KEY_NPAGE: # Page Down
                    if self.active_view == "tree":
                        self.current_lesson_idx = min(len(self.flat_lessons) - 1, self.current_lesson_idx + 10)
                    elif self.active_view == "content":
                         self.content_scroll_offset += 10
                    elif self.active_view == "output":
                         self.output_scroll_offset += 10
                
                # Jump Navigation
                elif key == ord('g'): # Top
                    if self.active_view == "tree":
                        self.current_lesson_idx = 0
                    elif self.active_view == "content":
                        self.content_scroll_offset = 0
                    elif self.active_view == "output":
                        self.output_scroll_offset = 0
                
                elif key == ord('G'): # Bottom
                    if self.active_view == "tree":
                        self.current_lesson_idx = len(self.flat_lessons) - 1
                    # For content/output, exact bottom is hard to calc without wrapping, so we skip
                    # Let's skip for content to avoid blank screens.

                elif key == ord('\t'):
                    # Cycle: Tree -> Content -> Output -> Editor -> Tree
                    if self.active_view == "tree": self.active_view = "content"
                    elif self.active_view == "content": self.active_view = "output"
                    elif self.active_view == "output": self.active_view = "editor"
                    else: self.active_view = "tree"
                
                elif key == curses.KEY_BTAB: # Shift+Tab
                    # Cycle Backwards
                    if self.active_view == "tree": self.active_view = "editor"
                    elif self.active_view == "editor": self.active_view = "output"
                    elif self.active_view == "output": self.active_view = "content"
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
        
        title = " Output (r: Run, e: Edit, q: Quit) "
        if self.active_view == "output":
             win.addstr(0, 2, title, curses.A_BOLD | curses.color_pair(2))
        else:
             win.addstr(0, 2, title)
        
        for i, line in enumerate(self.output_buffer[self.output_scroll_offset:]):
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
        if self.window_command_mode:
            status += " [W-CMD]"
        if len(status) > w - 2: status = status[:w-2]
        win.addstr(h - 1, 1, status, curses.A_REVERSE)
        
        if self.show_help:
            self._draw_help(win, h, w)

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
        if (self.editor_mode == "VISUAL" or self.editor_mode == "VISUAL_LINE") and self.visual_start:
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
                    
                    if self.editor_mode == "VISUAL":
                        if line_idx == sel_start[0]:
                            start_x = sel_start[1]
                        if line_idx == sel_end[0]:
                            end_x = sel_end[1] + 1 # inclusive
                    
                    # Clamp to display
                    start_x = max(0, min(start_x, len(display_str)))
                    end_x = max(0, min(end_x, len(display_str)))
                    
                    if start_x < end_x or (self.editor_mode == "VISUAL_LINE" and len(display_str) == 0):
                         # Highlight empty lines in visual line mode too (by printing a space)
                         if start_x == end_x and self.editor_mode == "VISUAL_LINE":
                             win.addstr(i + 1, 2, " ", curses.color_pair(5))
                         else:
                             win.addstr(i + 1, 2 + start_x, display_str[start_x:end_x], curses.color_pair(5))

        # Draw cursor if active
        if self.active_view == "editor":
            screen_y = self.editor_cy - self.editor_scroll + 1
            screen_x = self.editor_cx + 2
            screen_x = min(screen_x, w - 2)
            win.move(screen_y, screen_x)

        win.noutrefresh()

    def _draw_help(self, win, h, w):
        # Draw a box in the center
        box_h = 16
        box_w = 50
        start_y = (h - box_h) // 2
        start_x = (w - box_w) // 2
        
        # Ensure box fits
        if start_y < 0: start_y = 0
        if start_x < 0: start_x = 0
        
        # Draw background and border
        for i in range(box_h):
            if start_y + i >= h - 1: break
            win.addstr(start_y + i, start_x, " " * box_w, curses.A_REVERSE)
        
        # Content
        lines = [
            "      KEYBOARD CHEATSHEET      ",
            "-------------------------------",
            " Ctrl+w + h/j/k/l : Switch Pane",
            " Shift+Tab        : Cycle Back ",
            "-------------------------------",
            " i      : Insert Mode          ",
            " v / V  : Visual / Visual Line ",
            " d / dd : Delete Selection/Line",
            " y / yy : Yank Selection/Line  ",
            " p      : Paste                ",
            " u      : Undo                 ",
            " w / b  : Next/Prev Word       ",
            " ^ / $  : Start/End of Line    ",
            "-------------------------------",
            " Ctrl+/ : Toggle this help     "
        ]
        
        for i, line in enumerate(lines):
            if start_y + i + 1 >= h - 1: break
            # Center text in box
            padding = (box_w - len(line)) // 2
            text = " " * padding + line + " " * (box_w - len(line) - padding)
            win.addstr(start_y + i + 1, start_x, text[:box_w], curses.A_REVERSE)

    def _handle_editor_input(self, key):
        if self.editor_mode == "NORMAL":
            self._handle_normal_input(key)
        elif self.editor_mode == "INSERT":
            self._handle_insert_input(key)
        elif self.editor_mode == "VISUAL":
            self._handle_visual_input(key)

    def _handle_normal_input(self, key):
        self.editor_message = ""
        
        # Handle Pending Operator (dd, yy)
        if self.operator_pending:
            op = self.operator_pending
            self.operator_pending = None # Reset
            
            if op == 'd' and key == ord('d'):
                self._save_undo_state()
                line = self.editor_lines.pop(self.editor_cy)
                self.clipboard = [line]
                self.editor_message = "Line deleted"
                if not self.editor_lines: # Ensure at least one line
                    self.editor_lines = [""]
                if self.editor_cy >= len(self.editor_lines):
                    self.editor_cy = len(self.editor_lines) - 1
                self._clamp_cursor()
                return

            elif op == 'y' and key == ord('y'):
                line = self.editor_lines[self.editor_cy]
                self.clipboard = [line]
                self.editor_message = "Line yanked"
                return
            
            else:
                self.editor_message = "Cancelled"
                # Fallthrough to handle key as normal input? 
                # Standard Vim cancels the operator and ignores the key or treats it as new command.
                # Let's just cancel and ignore to be safe.
                return

        # Mode Switch
        if key == ord('i'):
            self._save_undo_state()
            self.editor_mode = "INSERT"
            self.editor_message = "-- INSERT --"
        elif key == ord('v'):
            self.editor_mode = "VISUAL"
            self.visual_start = (self.editor_cy, self.editor_cx)
            self.editor_message = "-- VISUAL --"
        elif key == ord('V'): # Shift+v
            self.editor_mode = "VISUAL_LINE"
            self.visual_start = (self.editor_cy, 0)
            self.editor_message = "-- VISUAL LINE --"
        
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
        
        # Home/End
        elif key == curses.KEY_HOME or key == ord('^') or key == ord('0'):
            self.editor_cx = 0
        elif key == curses.KEY_END or key == ord('$'):
            self.editor_cx = len(self.editor_lines[self.editor_cy])

        # Word Navigation
        elif key == ord('w'):
            self._move_word_forward()
        elif key == ord('b'):
            self._move_word_backward()

        # Actions
        elif key == ord('x'): # Delete char
            self._save_undo_state()
            line = self.editor_lines[self.editor_cy]
            if self.editor_cx < len(line):
                self.editor_lines[self.editor_cy] = line[:self.editor_cx] + line[self.editor_cx+1:]
        
        elif key == ord('d'):
             self.operator_pending = 'd'
             self.editor_message = "d..."
        
        elif key == ord('y'):
             self.operator_pending = 'y'
             self.editor_message = "y..."

        elif key == ord('p'): # Paste
            if self.clipboard:
                self._save_undo_state()
                # Insert after current line
                for line in reversed(self.clipboard):
                    self.editor_lines.insert(self.editor_cy + 1, line)
                self.editor_cy += len(self.clipboard)
                self.editor_message = "Pasted"
            else:
                self.editor_message = "Clipboard empty"

        elif key == ord('u'): # Undo
            if self.undo_stack:
                lines, cy, cx = self.undo_stack.pop()
                self.editor_lines = lines # Restore lines
                self.editor_cy = cy
                self.editor_cx = cx
                self.editor_message = "Undo"
            else:
                self.editor_message = "Already at oldest change"

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
        self.editor_message = "-- VISUAL --" if self.editor_mode == "VISUAL" else "-- VISUAL LINE --"
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
             self._perform_visual_op('y')
        
        elif key == ord('d') or key == ord('x'): # Delete selection
             self._perform_visual_op('d')

        self._clamp_cursor()
    
    def _perform_visual_op(self, op):
        if not self.visual_start: return
        
        p1 = self.visual_start
        p2 = (self.editor_cy, self.editor_cx)
        if p1 > p2: p1, p2 = p2, p1
        
        start_y, start_x = p1
        end_y, end_x = p2
        
        if self.editor_mode == "VISUAL_LINE":
            # Select full lines
            lines = self.editor_lines[start_y : end_y + 1]
            self.clipboard = lines
            
            if op == 'd':
                self._save_undo_state()
                del self.editor_lines[start_y : end_y + 1]
                if not self.editor_lines: self.editor_lines = [""]
                self.editor_cy = min(start_y, len(self.editor_lines) - 1)
                self.editor_message = f"Deleted {len(lines)} lines"
            else:
                self.editor_message = f"Yanked {len(lines)} lines"
                self.editor_mode = "NORMAL" # Exit visual mode after yank
                self.visual_start = None
                return

        else: # Normal VISUAL
            # For simplicity, let's force VISUAL to act line-wise for yank/delete to avoid breaking paste.
            lines = self.editor_lines[start_y : end_y + 1]
            self.clipboard = lines
            
            if op == 'd':
                self._save_undo_state()
                del self.editor_lines[start_y : end_y + 1]
                if not self.editor_lines: self.editor_lines = [""]
                self.editor_cy = min(start_y, len(self.editor_lines) - 1)
                self.editor_message = "Deleted selection"
            else:
                self.editor_message = "Yanked selection"

        self.editor_mode = "NORMAL"
        self.visual_start = None
            
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
        self.output_scroll_offset = 0
        # Force immediate refresh of output window to show "Compiling..."? 
        # In this loop structure, it won't show until next frame.
        # To make it show immediately, we'd need to redraw output and refresh.
        # But let's keep it simple.
        
        with tempfile.TemporaryDirectory() as tmp_dir:
            fname = lesson.get("filename", "solution.nim")
            tmp_path = Path(tmp_dir) / fname
            # Ensure parent dirs exist for the main file too
            tmp_path.parent.mkdir(parents=True, exist_ok=True)
            tmp_path.write_text(user_code, encoding="utf-8")
            
            result = self.engine.run_code(
                tmp_path,
                args=lesson.get("args"),
                project_files=lesson.get("files"),
                compile_cmd=lesson.get("cmd", "c"),
                project_root=Path(tmp_dir),
                skip_run=lesson.get("skip_run", False),
                compiler_args=lesson.get("compiler_args")
            )
            
            success, msg = self.engine.validate_lesson(lesson, user_code, result)
            
            self.output_buffer = msg.split('\n')
            
            if success:
                self.progress.add(lesson["id"])
                self.engine.save_progress(self.progress)

    def _show_hint(self):
        lesson = self.flat_lessons[self.current_lesson_idx]
        hint = lesson.get("hint", "No hint available.")
        self.output_buffer = ["--- HINT ---", hint]
        self.output_scroll_offset = 0

    def _show_solution(self):
        lesson = self.flat_lessons[self.current_lesson_idx]
        sol = lesson.get("solution", "No solution available.")
        self.output_buffer = ["--- SOLUTION ---"] + sol.split('\n')
        self.output_scroll_offset = 0
