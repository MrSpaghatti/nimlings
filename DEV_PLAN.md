# Development Plan

**Last updated:** 2026-07-19

> This document is a snapshot of the project at a point in time.
> For live project status, see [`STATUS.md`](./STATUS.md).
> For recent changes, see [`CHANGELOG.md`](./CHANGELOG.md).

## Current State (`main`)

- **Version:** 2.1.9
- **Lessons:** 255 across 4 levels, 55 chapters — all verified
- **Build:** Clean — zero warnings with `--warnings:on`
- **Tests:** 4 suites (28 tests): Content (2), Engine (5), Models (14), Prerequisites (7)
- **E2E:** 255/255 lessons pass `nimlings test` (100%)
- **CI:** GitHub Actions workflow at `.github/workflows/ci.yml`

## Upcoming Work

All 255 lessons verify end-to-end. 12 lessons are `skipRun: true` reference material
(topics that don't fit one-shot compile+run: async servers, SDL2, ObjC interop, etc.).
Ready for curriculum expansion.

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