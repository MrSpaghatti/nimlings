# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.10] — 2026-08-02

### Fixed

- **`ConfigDir` was a compile-time `const`** (`src/models.nim`): `getHomeDir()` was evaluated once at compile time and baked into the binary, so `loadProgress`/`saveProgress`/`ensureConfigDir` always resolved to the *build machine's* `$HOME` regardless of who actually ran the binary or what `$HOME` was set to at runtime — while `reset`/`export` (which call `getHomeDir()` inline in `nimlings.nim`) correctly used the runtime value. On any machine/account where build-time and run-time `$HOME` differ, progress would silently be read from and written to the wrong directory, and `reset` would appear to succeed while leaving the real progress file untouched. Fixed: `const` → `let`, so it's resolved once at process startup instead.
- **`status` count included non-lesson IDs** (`src/nimlings.nim`): `status` printed the raw size of the stored progress set (`saved.len`), while `list`/`path` validated each entry against the real lesson tree. Stray/legacy entries in `progress.json` (e.g. chapter- or level-style IDs left over from an older format, or anything let in by `import`) inflated `status`'s count without showing up in `list`, so the two commands could disagree on how many lessons were actually done. Fixed: `status` now counts only entries that match a real lesson ID, matching `list`/`path`.
- **`import` accepted arbitrary strings into progress.json** (`src/nimlings.nim`): Any string in the imported JSON array was added to progress with no check that it corresponded to a real lesson. Fixed: `import` now validates each ID against the lesson tree via `findLesson`, skips unrecognized ones, and reports how many were skipped.

## [2.1.9] — 2026-07-24

### Fixed

- **Lesson 3.15.1 accepted any compilable code** (`src/lessons.json`): The `validation_code` for "refc GC" was empty while `skip_run` was `false`. The generator converts empty `validation_code` to `return true`, so any program that compiled passed the lesson. Fixed: `validation_code` now `result.stdout.strip() == "Nodes created"`; `content.nim` regenerated. (Audit E1 — the single critical finding.)
- **`updateStreak` could raise uncaught `IndexDefect` on malformed dates** (`src/models.nim`): The date-split array access (`split("-")[0..2]`) had no length check. A malformed `lastLessonDate` in `daily.json` would raise `IndexDefect` (a `Defect`, not caught by the `except ValueError` handler) and crash the app. Fixed: added explicit `len != 3` check that raises `ValueError` (which IS caught), resetting the streak gracefully. (Audit E3.)
- **`defer removeDir` in `runCode` lacked error handling** (`src/engine.nim`): If `removeDir` failed (permissions race, NFS), the exception propagated uncaught and terminated the program. The sibling `cleanupOldTempDirs` already wrapped `removeDir` in `try/except: discard`. Fixed: `defer` block now wraps `removeDir` in `try/except: discard` for consistency. (Audit E4.)

### Changed

- **`test_prereqs` now imported in test runner** (`tests/runner.nim`): The runner imported `test_models, test_content, test_engine` but omitted `test_prereqs`, so `nim c -r tests/runner.nim` would silently skip all 7 prerequisite tests. `nimble test` was unaffected (it compiles each `test_*.nim` separately). Fixed: added `test_prereqs` to the import list. (Audit I3.)
- **Generator `($ %k)` → `$k` for `files` dict keys** (`tools/generator.nim`): The `%` operator wrapped the string key in a `JsonNode`, then `$` stringified it as JSON (double-quoted). Correct is plain `$k`. Unreachable currently (no lessons have non-empty `files`), but would produce broken table keys if any lesson added project files. (Audit I4.)
- **STATUS.md `skipRun` count corrected** — 12 → 35. The 12 figure was from v2.1.7 (only the 14 known-failing lessons considered, 2 later fixed). 23 additional conceptual/reference lessons are also `skipRun`. (Audit S1.)
- **STATUS.md date updated** — 2026-07-20 → 2026-07-24. (Audit S2.)

### Tests

- **2 new regression tests** (`tests/test_models.nim`): "malformed lastLessonDate doesn't crash" and "malformed todayDate doesn't crash" — verify that corrupted date strings in `daily.json` reset the streak gracefully instead of raising `IndexDefect`. Test count: 26 → 28.

### Docs

- **AUDIT.md**: Full deep-dive audit (6 parallel scout subagents + source verification) — 1 critical bug (E1: empty validator), 3 low-severity bugs (E3, E4, E2-investigated), 4 inefficiencies, 4 style/consistency items. E2 ("past-date overwrites lastLessonDate") investigated and confirmed as intentional tested behavior — NOT a bug.


## [2.1.8] — 2026-07-21

### Fixed

- **Project workspace wiped on every run** (`src/engine.nim`): `runCode` unconditionally `removeDir`'d the project workspace before `createDir`, deleting all project state before each run — contradicting the documented "persistent workspace, NOT cleaned up automatically" contract. Removed the pre-delete block; `createDir` is a no-op when the dir exists. (Audit E1.)
- **Bare `except:` in `loadProgress` and `loadDaily`** (`src/models.nim`): Both caught all exceptions including `Defect`, silently resetting progress/streak on any unexpected error. Narrowed to `JsonParsingError, JsonKindError, IOError` for consistency with the v2.1.6 `updateStreak` fix. (Audit I2.)
- **Dead code removed** (`src/nimlings.nim`): `removeFile("state.json")` in the `reset` command referenced a file removed in v2.1.2. (Audit S4.)

### Changed

- **Version sync**: Source constant and nimble file bumped 2.1.6 → 2.1.8 (the 2.1.7 release was doc-only by design and never touched the source constant; this release carries the source change). (Audit E2/S3.)
- **`compilerArgs` now quoted in shell commands** (`src/engine.nim`): Each compiler arg is now passed through `quoteShell()` before being concatenated into the compile command, matching how the filename and run args are already handled. Latent robustness fix — no current lesson triggers it. (Audit I1.)
- **`/tmp` cleanup scoped to `nimlings_*` glob** (`src/engine.nim`): `cleanupOldTempDirs` now uses `walkDirs(getTempDir() / "nimlings_*")` instead of iterating the entire `/tmp` and string-matching. (Audit I3.)
- **Generator validates `validation_code`** (`tools/generator.nim`): The generator now rejects `validation_code` containing newlines or triple-quotes at build time with a clear error naming the offending lesson, instead of silently emitting broken Nim. (Audit H1.)
- **README.md**: Corrected "25 Modules" to "55 Chapters across 4 levels". (Audit S1.)
- **STATUS.md**: Updated stale model assignments — only the Planner uses OpenRouter (Gemini 2.5 Flash); Smith/Fixer/Auditor run on local Qwen3.6-27B. (Audit S2.)

### Docs

- **AUDIT.md**: Full deep-dive audit (6 parallel scout subagents) — 1 bug, 2 consistency regressions, and low-impact polish items found; all actionable items fixed in this release.

## [2.1.7] — 2026-07-20

### Fixed

- **All 14 known-failing lessons resolved**: 12 structural-incompatibility lessons (async servers, SDL2, WebSocket, Fidget, compiler plugins, ObjC, etc.) now serve as `skipRun: true` reference material with correct solution code and code-structure validators. 2 lessons (3.15.3 ORC Model, 4.13.3 Inline Assembly) rewritten with working solutions that compile and run. `nimlings test` goes from 241/255 to 255/255.

### Changed

- **STATUS.md**: Updated to reflect 255/255 (100%) passing, replaced "Known-remaining failures" with resolution summary table.
- **DEV_PLAN.md**: Updated to 255/255.
- **AUDIT.md**: Marked all prior items resolved.
- **CHANGE_REPORT.md**: Replaced stale v2.1.6 report.

## [2.1.6] — 2026-07-20

### Fixed

- **JS mode missing `--warnings:off`**: The v2.1.5 fix added `--warnings:off` for `c`/`cpp` compilation, but JS mode builds its own compile command separately. Nim compiler warnings could pollute stdout and break lesson validators that do exact string matching. Fixed by adding `--hints:off --warnings:off` to the JS compile command (`src/engine.nim`).
- **Bare `except:` in `updateStreak`**: The `except:` clause in the date-parsing branch caught all exceptions including `Defect`, silently resetting the streak on any unexpected error. Narrowed to `except ValueError:` (`src/models.nim`).
- **Bare `except:` in watch mode file check**: `except: Time.high` caught all exceptions, not just `OSError`. Narrowed to `except OSError:` (`src/nimlings.nim`).
- **`checkNodeInstalled()` after JS compilation**: If Node.js was missing, the nim→js compilation ran to completion before failing. Moved the check before compilation so users don't wait for a doomed compile (`src/engine.nim`).
- **`initLessons()` before `-h`/`-v` guards**: 840KB of lesson data was deserialized even for help/version invocations. Moved `initLessons()` after the early-exit guards (`src/nimlings.nim`).

### Changed

- **Version synced**: Source constant and nimble file bumped from 2.1.3 → 2.1.6 (2.1.4 and 2.1.5 changes were recorded in CHANGELOG but never reflected in the version fields).
- **AUDIT.md**: Full deep-dive audit of all source files; 2 bugs, 3 inefficiencies, 2 style issues found; all actionable items fixed.
- **DEV_PLAN.md**: Version updated to 2.1.6.

## [2.1.5] — 2026-07-19

### Fixed

- **Temp dir leak in `runCode`**: Nim's `defer` fires when its enclosing *block* exits, not at proc scope. The `defer: removeDir(tmpDir)` was nested inside an `if lesson.lessonType != "project"` block, causing it to fire immediately — before `createDir(tmpDir)` re-created the directory. The re-created dir had no cleanup, leaking a temp dir on every `runCode` call. Fixed by moving `defer` to unconditional proc scope with the conditional inside the deferred body (`src/engine.nim`).

### Changed

- **AGENTS_READ_THIS.md**: Replaced the `/tmp` clutter rant with a concise agent reference covering build commands, architecture, gotchas, and key docs.
- **DEV_PLAN.md**: Updated version (2.1.4), lesson count (255), test suite count (26 across 4 suites), file sizes.
- **AUDIT.md**: Corrected test count (26, not 29; Engine has 5, not 6; no "Fixes" suite).
- **CHANGELOG.md**: Fixed v2.1.4 field count (9 fields, not 8).

### Removed

- **PLAN.md**: All items completed in v2.1.4; archived (recoverable via git).
- **progress.md**: Session complete; removed.

## [2.1.4] — 2026-06-26

### Fixed

- **Removed unused `import tables` from `engine.nim`** — verified it's actually needed for `pairs()` on `Table` via `types.nim`; the audit was wrong about this being redundant. (No change.)
- **Removed dead "State JSON round-trip" test** from `test_models.nim` — tested Nim's `json` module, not project code. Leftover from `State` type removal in v2.1.2.
- **Flattened useless conditional in `printDashboard`** (`src/tui.nim:59`) — all three branches produced `"🔥"`; replaced with `let fire = "🔥"`.
- **Extended Lesson Fields Integrity test** (`tests/test_content.nim`) — now validates `conceptText`, `task`, `solution`, `hint` (except `skipRun` lessons), and `difficulty` are non-empty. Caught 4 lessons with empty solution/hint (all `skip_run=True`, confirmed intentional).

### Changed

- **Test coverage**: Content integrity test now checks 9 fields (was 4).
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
