# Agent Instructions — nimlings

## Build & Test

```bash
nimble generate_content     # regenerate src/content.nim (if lessons.json changed)
nim c --warnings:on src/nimlings.nim   # build
nimble test -y              # all 4 test suites (Content, Engine, Models, Prerequisites)
./src/nimlings test         # run every lesson's solution against its validator
```

## Architecture

```
src/
├── nimlings.nim     — CLI entry, command dispatch, watch loop
├── engine.nim       — sandboxed compilation/execution (nim c/nim js), validation
├── tui.nim          — ANSI dashboard, progress bars, lesson headers
├── types.nim        — Lesson, Chapter, Level, RunResult, DocLink, LessonValidation
├── models.nim       — progress persistence (~/.config/nimlings/), daily streak
├── content.nim      — GENERATED from lessons.json (gitignored), do not edit
└── lessons.json     — source of truth, 255 lessons across 4 levels
tools/
└── generator.nim    — lessons.json → content.nim
tests/
├── test_content.nim — lesson field integrity (2 tests)
├── test_engine.nim  — validation, JS/project runners, timeout (5 tests)
├── test_models.nim  — streak date arithmetic (12 tests)
└── test_prereqs.nim — dependency graph correctness (7 tests)
```

## Gotchas

- **`defer` scoping**: Nim's `defer` fires when its enclosing *block* exits, NOT at proc exit.
  Never put `defer` inside an `if`/`for`/`while` — it fires at block end, not proc end.
  Always place `defer` directly at proc scope (no nesting).

- **content.nim is stale until regenerated**: `lessons.json` is the source of truth.
  After editing lessons, run `nimble generate_content` before building/testing.

- **`nimble install <anything>` from this directory** may also rebuild+register nimlings
  itself in `~/.nimble/pkgs2/`, shadowing local `src/`. Fix: `nimble uninstall nimlings`.

- **Project lessons** (lessonType "project") use `~/.config/nimlings/projects/<id>/`
  as persistent workspace, not /tmp. They are NOT cleaned up automatically.

- **Key docs**: `STATUS.md` (current state), `CHANGELOG.md` (history), `AUDIT.md` (UX/content audit).