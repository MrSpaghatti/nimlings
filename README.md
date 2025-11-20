# nimlings

`nimlings` is an interactive command-line application designed to take you from zero to professional in the Nim programming language. It's a single, self-contained Python script that you can run directly.

The tutor presents you with a concept, gives you a coding task, and then opens your default text editor for you to write a solution. It then compiles and runs your code, providing immediate feedback. All in a cynical, no-bullshit tone.

## What You Will Learn

An interactive, hands-on tutor for learning the **Nim programming language** through structured lessons and challenges in your terminal.

## What is nimlings?

nimlings is a guided, progressive learning tool designed to teach you Nim from zero to hero. It presents a curriculum of carefully structured lessons in an interactive TUI (text user interface), where you write code, get instant feedback, and build real understanding.

**Goal:** By completing nimlings, you will be able to write professional-grade Nim code with confidence.

## Features

- **Interactive TUI**: Code editor with Vim-like keybindings, syntax-aware navigation, and instant feedback
- **25 Modules**: From "Hello World" to web servers, covering the full Nim ecosystem
- **Smart Validation**: Each lesson validates your code logic and style
- **Progress Tracking**: Your progress is automatically saved
- **Helpful Feedback**: Clear error messages with actionable fix instructions
- **Built-in Cheatsheet**: Press `Ctrl+/` to see all keyboard shortcuts

## Prerequisites

- **Nim compiler** installed and available in your PATH
  - Install from https://nim-lang.org/install.html
  - Or use your package manager: `sudo apt install nim` / `brew install nim`
- **Python 3.8+**
- **Terminal** with Unicode support

## Installation

```bash
git clone https://github.com/yourusername/nimlings.git
cd nimlings
python3 nimlings.py learn
```

## Usage

### Start the Interactive Tutor

```bash
python3 nimlings.py learn
```

### Navigation

- **Tab**: Cycle through panes (Tree → Content → Output → Editor)
- **Shift+Tab**: Cycle backwards
- **Ctrl+w + h/j/k/l**: Vim-style pane switching
- **Arrow keys / hjkl**: Navigate within panes
- **Enter**: Select lesson (from tree)
- **e**: Focus editor
- **r**: Run code
- **q**: Quit (when not in editor)

### Editor (Vim-like)

- **i**: Enter Insert mode
- **ESC**: Return to Normal mode
- **v / V**: Visual / Visual Line mode
- **dd**: Delete line
- **yy**: Yank (copy) line
- **p**: Paste
- **u**: Undo
- **w / b**: Jump forward/backward by word
- **^ / $** or **Home/End**: Jump to start/end of line
- **Ctrl+/**: Toggle keyboard cheatsheet

### CLI Commands

```bash
python3 nimlings.py list        # List all lessons and progress
python3 nimlings.py reset       # Reset progress
python3 nimlings.py test        # Run internal tests
python3 nimlings.py hint <id>   # Get hint for a lesson
python3 nimlings.py solution <id>  # Show solution
```

## Curriculum

The curriculum is divided into **three phases**:

### Phase 1: Foundation (Modules 1-6)
Learn Nim basics: syntax, types, control flow, functions, and core data structures.

### Phase 2: Intermediate (Modules 7-18)
Explore advanced features: generics, async/await, macros, FFI, JSON, CLI tools, and optimization.

### Phase 3: Professional (Modules 19-25)
Build real-world skills: project structure, web development, testing, tooling, performance profiling, and a capstone web API project.

**Total**: 50+ lessons across 25 modules.

## Project Structure

```
nimlings/
├── nimlings.py          # CLI entry point
├── src/
│   ├── engine.py        # Core logic (lesson validation, Nim execution)
│   ├── tui.py           # Text UI with Vim-like editor
│   ├── lessons.py       # All lesson definitions
│   └── exceptions.py    # Custom error handling
├── tests/               # Test files
└── README.md
```

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new lessons
- Improve error messages
- Add features

## License

This project is open source.

## Acknowledgments

Inspired by rustlings and similar interactive learning tools.
