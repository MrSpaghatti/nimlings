# Change Report

**Date:** 2026-07-20
**Version:** 2.1.6
**Type:** Version sync + source audit + fixes

## Summary

Fixed 3-month version mismatch (source at 2.1.3, CHANGELOG had 2.1.4/2.1.5 entries). Ran full deep-dive audit of all source modules. Found 2 bugs, 3 inefficiencies, 2 style issues — all actionable items fixed.

## Files Modified

| File | Changes |
|------|---------|
| `src/nimlings.nim` | Bumped version 2.1.3→2.1.6; moved `initLessons()` after `-h`/`-v` guards; narrowed bare `except:` to `except OSError:` in watch mode |
| `src/engine.nim` | Added `--hints:off --warnings:off` to JS compile command; moved `checkNodeInstalled()` before JS compilation |
| `src/models.nim` | Narrowed bare `except:` to `except ValueError:` in `updateStreak` |
| `nimlings.nimble` | Version 2.1.3→2.1.6 |
| `CHANGELOG.md` | Added v2.1.6 entry |
| `STATUS.md` | Updated date, added 2026-07-20 session notes, fixed suite count (5→4), added version row |
| `DEV_PLAN.md` | Version 2.1.4→2.1.6 |
| `AUDIT.md` | Full rewrite with 2026-07-20 audit findings |
| `CHANGE_REPORT.md` | This file — replaced stale v2.1.4 report |

## Key Decisions

- **Version jump 2.1.3→2.1.6**: 2.1.4 and 2.1.5 were documented in CHANGELOG but never synced to source. Today's audit fixes are 2.1.6.
- **Deferred I3, S2**: `cleanupOldTempDirs` walking entire `/tmp` and `RunResult.stderr` dead field — both very low impact, not worth churn.
- **`except ValueError:` vs `except CatchableError:`**: Only `parseInt` can fail in the guarded block, so `ValueError` is the tightest correct scope.

## Verification

- [x] `nim c --warnings:on src/nimlings.nim` — zero warnings
- [x] `nimble test -y` — all 26 tests pass (4 suites)
- [x] `./src/nimlings -v` — reports 2.1.6
- [x] `./src/nimlings -h` — fast path (no lesson loading)
