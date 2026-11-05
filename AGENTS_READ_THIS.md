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
├── test_engine.nim  — validation, JS/project runners, timeout + >64KiB output (6 tests)
├── test_models.nim  — streak date arithmetic (14 tests)
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

- **Generator table keys must be quoted**: `std/json`'s `pairs` yields `(string, JsonNode)`,
  so `$k` on the key emits it UNQUOTED and the generated `files: {helpers.nim: ...}` is not
  valid Nim. Use `escape(k)`. This broke the build for 13 lessons until 2026-11-05.

- **`cleanupOldTempDirs` only removes dirs older than 10 minutes.** It used to delete every
  `/tmp/nimlings_*`, so a second `nimlings` invocation (even `nimlings list` from a shell
  prompt) destroyed the temp dir a running lesson was compiling in — surfacing as a bogus
  "COMPILE/RUN ERROR" with empty output. Never run two `nimlings` commands concurrently
  against the same lesson set while debugging that symptom.

- **`runWithTimeout` captures to a FILE, not a pipe.** A pipe's 64 KiB buffer deadlocks a
  chatty child. Do not "simplify" it back to `p.outputStream.readAll()`.

- **Key docs**: `STATUS.md` (current state + open items), `CHANGELOG.md` (history),
  `docs/archive/` (superseded plans and audits — history only).