# nimlings

`nimlings` is an interactive command-line application designed to take you from zero to professional in the Nim programming language.

**Now rewritten in 100% Nim!**

The tutor presents you with a concept, gives you a coding task, and then opens your default text editor for you to write a solution. It then compiles and runs your code in a sandboxed environment, providing immediate feedback. All in a cynical, no-bullshit tone.

## Features

- **Interactive TUI**: Navigate lessons and view feedback in a terminal interface.
- **Bring Your Own Editor**: Seamlessly integrates with your favorite editor (Vim, VS Code, Nano, etc.).
- **Auto-Check**: Automatically detects file changes and verifies your solution in the background.
- **Sandboxed Execution**: User code runs with a 5-second timeout to prevent infinite loops.
- **Smart Hints**: Parses scary compiler errors into friendly (or cynical) hints.
- **25 Modules**: From "Hello World" to web servers, covering the full Nim ecosystem.
- **Progress Persistence**: Export/Import your progress to move between machines.

## Prerequisites

- **Nim compiler** (1.6 or higher) installed and available in your PATH.
  - Install from https://nim-lang.org/install.html
- **Nimble** (usually comes with Nim).
- **Terminal** with Unicode support.

## Installation

```bash
git clone https://github.com/yourusername/nimlings.git
cd nimlings

# Build the application (this will also generate lesson content)
nimble build -y
```

This produces a `nimlings` binary in the current directory (or where nimble places binaries).

## Usage

### Start the Interactive Tutor

```bash
./nimlings
# OR explicitly
./nimlings learn
```

### Navigation (TUI)

- **Arrow keys / j/k**: Navigate lesson list.
- **Enter / e**: Open the current lesson in your `$EDITOR`.
- **r**: Manually trigger verification.
- **h / ?**: Show hint.
- **Tab**: Cycle through views (Curriculum -> Lesson -> Output).
- **q**: Quit.

The tutor monitors the current exercise file. As soon as you save your changes in your editor, `nimlings` will automatically compile and check your code.

### CLI Commands

```bash
./nimlings watch [id]     # Start in Watch Mode (CLI only, no TUI)
./nimlings list           # List all lessons and progress
./nimlings reset          # Reset progress
./nimlings test           # Run internal tests
./nimlings hint <id>      # Get hint for a lesson
./nimlings solution <id>  # Show solution
./nimlings export         # Export progress to JSON (stdout)
./nimlings import [file]  # Import progress from JSON file
```

## Project Structure

```
nimlings/
├── src/
│   ├── nimlings.nim     # CLI entry point
│   ├── engine.nim       # Core logic (compilation, validation, sandboxing)
│   ├── tui.nim          # Terminal UI (using illwill)
│   ├── models.nim       # Data models & persistence
│   ├── types.nim        # Type definitions
│   └── lessons.json     # Raw lesson data
├── tools/
│   └── generator.nim    # Tool to generate src/content.nim from lessons.json
├── nimlings.nimble      # Package & Build definition
└── README.md
```

## Contributing

Contributions are welcome!
To add lessons, edit `src/lessons.json`. The build system (`nimble build`) automatically runs the generator to update the application logic.

## License

This project is open source (MIT).
