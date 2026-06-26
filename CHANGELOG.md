# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [2.1.4] — 2026-06-26

### Fixed

- **Removed unused `import tables` from `engine.nim`** — verified it's actually needed for `pairs()` on `Table` via `types.nim`; the audit was wrong about this being redundant. (No change.)
- **Removed dead "State JSON round-trip" test** from `test_models.nim` — tested Nim's `json` module, not project code. Leftover from `State` type removal in v2.1.2.
- **Flattened useless conditional in `printDashboard`** (`src/tui.nim:59`) — all three branches produced `"🔥"`; replaced with `let fire = "🔥"`.
- **Extended Lesson Fields Integrity test** (`tests/test_content.nim`) — now validates `conceptText`, `task`, `solution`, `hint` (except `skipRun` lessons), and `difficulty` are non-empty. Caught 4 lessons with empty solution/hint (all `skip_run=True`, confirmed intentional).

### Changed

- **Test coverage**: Content integrity test now checks 8 fields (was 4).
- **AUDIT.md**: Updated with current zero-bug findings.

## [2.1.3] — 2026-06-14

### Added

- **Streak date logic tests**: Extracted `updateStreak` pure proc from `recordLessonCompletion` for testability; 13 test cases covering first lesson, same day, consecutive day, month/year boundaries, gaps, and past dates (`src/models.nim`, `tests/test_models.nim`)
- **GitHub Actions CI**: Build, test, and warning-verification workflow for push/PR to `main` (`.github/workflows/ci.yml`)

### Fixed

- **Test isolation**: Moved `byId` declaration before `setup` in prereq tests and added `teardown` for defensive cleanup (`tests/test_prereqs.nim`)

### Docs

- **DEV_PLAN.md** updated: replaced stale branch-management content with current project snapshot and cross-references to canonical docs
- **progress.md** filled: converted from empty boilerplate to actual session tracker

## [2.1.2] — 2026-06-14

### Added

- **22 new lessons** across 9 new chapters:
  - L2: Regex (3), Data Structures (3), OS & Filesystem (3), DateTime (2)
  - L3: Encoding (2), Text Parsing & Streams (3)
  - L4: Networking (3), Publishing & Documentation (3)
  - Total: 142 lessons

### Fixed

- **Version sync**: Source constant now matches nimble file (both 2.1.0 → both 2.1.2)
- **Stack traces restored**: Removed `--d:release` from `nimlings.nims` for dev builds
- **Noisy data loss**: Added `stderr` warnings on corrupt progress/daily/state files instead of silent `discard`
- **Dead fields**: Removed unused `Progress` type, `saveState`/`loadState` procs, and `StateFile` constant from models
- **Unused import**: Removed `tables` import from generator
- **Node.js check**: `runCode` now verifies Node.js is installed before JS lesson execution
- **Regex naming**: Renamed `Re*` variables to `*Re` convention (Nim-idiomatic)
- **`canSkip` overload**: Added `canSkip(lesson, progress)` to skip redundant lesson lookup
- **`findLessonById` dedup**: Delegates to `findLesson` instead of duplicating iteration
- **`printLessonHeader` defense**: Guards against empty `conceptText`
- **`printHelp` cleanup**: Single `echo` with multi-line string instead of 22 separate `echo` calls
- **Polling tweak**: `runWithTimeout` polls at 100ms instead of 50ms (50 → 25 iterations)
- **Generator cleanup**: Removed unused `chapId`, `chapName`, `levelName` variables

## [2.1.1] — 2026-06-14

### Added

- `difficulty` field to 44 lessons across all levels (was only on newer lessons)
- `cross_language_notes` field to 44 lessons (was only on newer lessons)
- `STATUS.md` for project status tracking
- `CHANGE_REPORT.md` for this change cycle

### Fixed

- N/A — content enrichment only, no bug fixes

## [2.1.0] — 2026-06-13

### Added

- 120 lessons across 4 levels (30 each)
- Prerequisite tree with root at 1.1.1
- Level gating via boss lessons
- Cross-language notes on select lessons
- `nimlings path` CLI command for upgrade path visualization
- `--force` flag to bypass prerequisite checks
- Project mode (nimble test runner) for multi-file lessons
- JS compilation backend support
- Daily streak tracking
- Sandboxed execution with 5-second timeout
- TUI dashboard with ANSI progress bars
- All CLI commands: learn, watch, list, reset, test, hint, solution, export, import, status, path

### Fixed

- `runWithTimeout` race condition dropping output (stabilize-repo merge)
- Project runner integration (manual-merge-project-runner)
