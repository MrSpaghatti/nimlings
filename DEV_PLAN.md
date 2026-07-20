# Development Plan

**Last updated:** 2026-07-19

> This document is a snapshot of the project at a point in time.
> For live project status, see [`STATUS.md`](./STATUS.md).
> For recent changes, see [`CHANGELOG.md`](./CHANGELOG.md).

## Current State (`main`)

- **Version:** 2.1.6
- **Lessons:** 255 across 4 levels, 55 chapters
- **Build:** Clean — zero warnings with `--warnings:on`
- **Tests:** 4 suites (26 tests): Content (2), Engine (5), Models (12), Prerequisites (7)
- **E2E:** 241/255 lessons pass `nimlings test` (14 known structural failures documented in STATUS.md)
- **CI:** GitHub Actions workflow at `.github/workflows/ci.yml`

## Upcoming Work

See `STATUS.md` for the 14 known-remaining lesson failures — these are structural issues
(lessons that don't fit the "compile one file, run it, check stdout" model).

## Key Files

| File | Purpose |
|------|---------|
| `src/nimlings.nim` | CLI entry point — command dispatch, watch mode, main loop |
| `src/engine.nim` | Compilation, validation, error hint parsing, sandboxing, /tmp cleanup |
| `src/tui.nim` | ANSI dashboard, progress bars, lesson headers |
| `src/models.nim` | Progress persistence (JSON), daily streaks, date arithmetic |
| `src/types.nim` | Core types: Lesson, Chapter, Level, RunResult |
| `src/content.nim` | **GENERATED** (~840KB) — all 255 lessons with per-lesson validators |
| `src/lessons.json` | Source of truth (~909KB) — content input for generator |
| `tools/generator.nim` | Transforms `lessons.json` → `src/content.nim` |
| `tests/` | 4 test suites (see above) |

## Branch Status

- **`main`** — Active development. All branches merged and stable.
- No other active branches.
- Git history is linear.