# Development Status

**Last updated:** 2026-06-14

> This file is a historical artifact from the early branch-management phase.
> For live project status, see [`STATUS.md`](./STATUS.md).
> For recent changes, see [`CHANGELOG.md`](./CHANGELOG.md).
> For the current improvement plan, see [`PLAN.md`](./PLAN.md).

## Historical Context

Previous versions of this file tracked branch management concerns (`fix-runwithtimeout-regression`, `manual-merge-project-runner`, `stabilize-repo`).
All those branches have been merged into `main` and the repository is stable.

## Current State (`main`)

- **Version:** 2.1.2
- **Lessons:** 142 across 4 levels (30 + new topics)
- **Audit:** All 16 findings resolved (see `AUDIT.md`)
- **Build:** Clean — zero warnings with `--warning:all`
- **Tests:** 5 suites, all passing
- **CI:** GitHub Actions workflow at `.github/workflows/ci.yml`

## Key Files

| File | Purpose |
|------|---------|
| `src/nimlings.nim` | CLI entry point — command dispatch, watch mode, main loop |
| `src/engine.nim` | Compilation, validation, error hint parsing, sandboxing |
| `src/tui.nim` | ANSI dashboard, progress bars, lesson headers |
| `src/models.nim` | Progress persistence (JSON), daily streaks, date arithmetic |
| `src/types.nim` | Core types: Lesson, Chapter, Level, RunResult |
| `src/content.nim` | Generated (3K lines) — all 142 lessons with per-lesson validators |
| `src/lessons.json` | Source of truth — content input for generator |
| `tools/generator.nim` | Transforms `lessons.json` → `src/content.nim` |
| `tests/` | 5 test suites (Content, Engine, Models, Prerequisites, Solutions) |

## Branch Status

- **`main`** — Active development. All branches merged and stable.
- No other active branches. Feature branches are merged or historical.
- Git history is linear and clean.
