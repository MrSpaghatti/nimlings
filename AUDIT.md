# Audit Report

**Date:** 2026-07-20
**Scope:** All source files, test files, generator
**Focus:** Bugs, inefficiencies, hallucinations, style

---

## Errors (actual bugs)

- [ ] **E1: JS mode missing `--warnings:off`** — `src/engine.nim:149`
  JS mode builds its own `compileCmd` without `--warnings:off`. Nim compiler warnings go to stdout and can break validators doing exact string matching. Same class of bug that was fixed for `c`/`cpp` mode in v2.1.5 (line 167), which broke double-digit lessons.

- [ ] **E2: Bare `except:` in `updateStreak` silently resets streak** — `src/models.nim:118`
  Catches everything including `Defect`. On any unexpected error, the streak silently resets to 1, masking the root cause. Should be `except ValueError:` (only `parseInt` can fail here).

## Inefficiencies

- [ ] **I1: `checkNodeInstalled()` called after JS compilation** — `src/engine.nim:159`
  If Node.js is missing, nim→js compilation runs to completion before failing with "Node.js not found." Move the check before compilation so the user doesn't wait for a doomed compile.

- [ ] **I2: `initLessons()` runs before param parsing** — `src/nimlings.nim:168`
  840KB of lesson data deserialized even for `-h` and `-v`. Move `initLessons()` after the help/version guards.

- [ ] **I3: `cleanupOldTempDirs` walks entire `/tmp`** — `src/engine.nim:13`
  Iterates all entries in `/tmp` to find `nimlings_*` dirs. Minor on most systems, but O(n) over all temp files.

## Style / Consistency

- [ ] **S1: Bare `except:` in watch mode file check** — `src/nimlings.nim:152`
  `except: Time.high` catches all exceptions, not just `OSError`. Should be `except OSError: Time.high`.

- [ ] **S2: `RunResult.stderr` always empty** — `src/types.nim:44`
  Field exists but is never populated (engine uses `poStdErrToStdOut` which merges stderr into stdout). Dead weight, but changing it would touch generated lesson validators that reference the parameter.

## Info (observations, not action items)

- `today()` uses manual string formatting instead of `times.format(now, "yyyy-MM-dd")` (`models.nim:40-42`). Works correctly.
- `execCmd("nim --version")` compiles a trivial program to check Nim exists (`engine.nim:28`). `findExe("nim")` would be lighter.
- `--warnings:off` only added for `c`/`cpp` modes (`engine.nim:166`). `r` mode doesn't get it. Currently no lessons use `r` mode.
- `canSkip(id)` overload iterates all 255 lessons per call (`engine.nim:197-208`). Acceptable at this scale.

## Verification

- [x] `nim c --warnings:on src/nimlings.nim` — clean (0 warnings)
- [x] `nimble test -y` — all 26 tests pass (Content: 2, Engine: 5, Models: 12, Prerequisites: 7)
- [x] Version sync fixed: both `nimlings.nim` and `nimlings.nimble` now at 2.1.5
- [x] All API calls verified against real Nim 2.2 stdlib — no hallucinations