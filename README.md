# nimlings

An interactive, terminal-based tutor that takes you from zero to productive in
[Nim](https://nim-lang.org) — in the spirit of `rustlings`, but with a curriculum, a
prerequisite tree, and a streak.

```
  ╔══════════════════════════════════════════════════════════════╗
  ║          nimlings — Interactive Nim Tutor           ║
  ╚══════════════════════════════════════════════════════════════╝

    🔥 Streak: 1 days
      Today: 2 lesson(s) done

    Overall Progress   2/255 lessons
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0%

    Levels

    Level 1: Foundations  (2/34)
    ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 5%

      ⟳ Your First Code  (1/5)
        ◆ 1.1.1: Intro
        ◇ 1.1.2: Hello World
        ◇ 1.1.3: Compiling & Running
        ◇ 1.1.4: Comments
        ◇ 1.1.5: Basic I/O
```

That is real output from `nimlings list`, not a mockup.

## How it works

1. `nimlings learn` shows the dashboard and drops you into your next lesson.
2. It writes an exercise file and opens it in `$EDITOR`.
3. You save. nimlings compiles and runs the file, then validates the output.
4. Wrong? You get a parsed hint instead of a raw compiler dump.

## Features

- **CLI-first** — dashboard, watch mode, and a prerequisite tree; no GUI.
- **Bring your own editor** — Vim, Helix, VS Code, Nano, anything `$EDITOR` points at.
- **Auto-check on save** — watch mode recompiles and re-validates in the background.
- **Timeout-guarded execution** — your code runs in a temp directory with a 5-second
  timeout, so an infinite loop can't hang the tutor.
- **Parsed hints** — common compiler errors are turned into plain-English (and cynical)
  hints.
- **255 lessons, 4 levels, 55 chapters** — from `echo` to compiler plugins.
- **Progress persistence** — streaks, plus `export`/`import` to move between machines.

## Requirements

- **Nim** 1.6 or newer on `PATH` ([install](https://nim-lang.org/install.html))
- **Nimble** (ships with Nim)
- A terminal with Unicode support

## Install

```bash
git clone https://github.com/MrSpaghatti/nimlings.git
cd nimlings
nimble build -y
```

`nimble build` also regenerates `src/content.nim` from `src/lessons.json`.

## Usage

```bash
./nimlings                 # dashboard + start the next lesson
./nimlings learn           # same, explicitly
./nimlings watch 4.9.1     # jump to a lesson (--force to skip prerequisite checks)
./nimlings list            # progress dashboard
./nimlings path            # recommended upgrade path
./nimlings hint 1.1.2      # hint for a lesson
./nimlings solution 1.1.2  # show the solution
./nimlings export          # progress as JSON on stdout
./nimlings import prog.json
./nimlings test            # validate every lesson's solution
```

## What "255/255 verified" actually means

The curriculum is 255 lessons across 4 levels and 55 chapters. `nimlings test` validates
all of them, but not all in the same way:

- **220 lessons are executed end-to-end** — the solution is compiled, run, and its output
  checked by a per-lesson validator.
- **35 lessons are `skip_run`** — reference material for topics that cannot be tested
  one-shot: async servers that never exit, raw sockets, compiler plugins, macOS-only
  Objective-C interop. Their validators check the *code's structure* (required imports,
  calls, patterns) instead of runtime output.

So the 255/255 figure is honest about its own coverage, but it is not "255 programs proven
correct". The 220 behavioural checks are the real signal.

## Project structure

```
src/
├── nimlings.nim     CLI entry, command dispatch, watch loop
├── engine.nim       compilation/execution, validation, hint parsing
├── tui.nim          ANSI dashboard, progress bars
├── models.nim       progress persistence (~/.config/nimlings/), streaks
├── types.nim        Lesson, Chapter, Level, RunResult
├── content.nim      GENERATED from lessons.json (gitignored — do not edit)
└── lessons.json     source of truth: 255 lessons
tools/
├── generator.nim    lessons.json -> content.nim
└── add_docs.py      one-off helper for bulk doc-link edits (Python)
tests/               4 suites, 29 tests
docs/archive/        superseded plans and audits (history only)
```

## Status

| Check | Result |
|---|---|
| Build | `nimble build` clean, v2.1.10 |
| Unit tests | 29/29 across 4 suites |
| `nimlings test` | 255/255 (220 executed, 35 structure-validated) |

See [STATUS.md](STATUS.md) for current state and open items, [CHANGELOG.md](CHANGELOG.md)
for history, and [AGENTS_READ_THIS.md](AGENTS_READ_THIS.md) if you are an AI agent working
in this repo.

## Contributing

Lessons live in `src/lessons.json`; run `nimble build` (or `nimble generate_content`) after
editing them. Every lesson needs a `validation_code` expression — an empty one silently
becomes `return true` and accepts any compilable program.

## License

MIT — see [LICENSE](LICENSE).
