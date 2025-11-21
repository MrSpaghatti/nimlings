# nimlings

`nimlings` is an interactive command-line application designed to take you from zero to professional in the Nim programming language.

**Now rewritten in 100% Nim!**

The tutor presents you with a concept, gives you a coding task, and then opens your default text editor for you to write a solution. It then compiles and runs your code, providing immediate feedback. All in a cynical, no-bullshit tone.

## Features

- **Interactive TUI**: Navigate lessons and view feedback in a terminal interface.
- **Bring Your Own Editor**: Seamlessly integrates with your favorite editor (Vim, VS Code, Nano, etc.).
- **Auto-Check**: Automatically detects file changes and verifies your solution in the background.
- **25 Modules**: From "Hello World" to web servers, covering the full Nim ecosystem.
- **Smart Validation**: Each lesson validates your code logic.
- **Progress Tracking**: Your progress is automatically saved.

## Prerequisites

- **Nim compiler** installed and available in your PATH.
  - Install from https://nim-lang.org/install.html
- **Terminal** with Unicode support.

## Installation

```bash
git clone https://github.com/yourusername/nimlings.git
cd nimlings
nimble install -y illwill
nim c -d:release --threads:on src/nimlings.nim
```

## Usage

### Start the Interactive Tutor

```bash
./src/nimlings learn
```

### Navigation

- **Arrow keys / j/k**: Navigate lesson list.
- **Enter / e**: Open the current lesson in your `$EDITOR`.
- **r**: Manually trigger verification.
- **Tab**: Cycle through views (Curriculum -> Lesson -> Output).
- **q**: Quit.

The tutor monitors the current exercise file. As soon as you save your changes in your editor, `nimlings` will automatically compile and check your code.

### CLI Commands

```bash
./src/nimlings list        # List all lessons and progress
./src/nimlings reset       # Reset progress
./src/nimlings test        # Run internal tests
./src/nimlings hint <id>   # Get hint for a lesson
./src/nimlings solution <id>  # Show solution
```

## Project Structure

```
nimlings/
├── src/
│   ├── nimlings.nim     # CLI entry point
│   ├── engine.nim       # Core logic (compilation, validation)
│   ├── tui.nim          # Terminal UI (using illwill)
│   ├── content.nim      # Generated lesson content
│   ├── models.nim       # Data models & persistence
│   └── types.nim        # Type definitions
├── tools/
│   └── generate_content.py # Tool to generate content.nim from JSON/Python
└── README.md
```

## Contributing

Contributions are welcome!
To add lessons, edit `src/lessons.json` (if you have it) or modify the generator `tools/generate_content.py`.

## License

This project is open source.
