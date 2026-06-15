# Change Report

**Date:** 2026-06-14
**Type:** Polish round — tests, CI, and housekeeping

## Summary

Executed the 5-item polish plan from PLAN.md. Version bumped to 2.1.3.

## Files Modified

| File | Changes |
|------|---------|
| `src/models.nim` | Extracted `updateStreak(daily, todayDate)` pure proc from `recordLessonCompletion` for testability — same logic, no behavior change |
| `tests/test_models.nim` | 13 test cases for streak date logic: first lesson, same day, consecutive day, month/year boundaries, gaps, past dates |
| `tests/test_prereqs.nim` | Moved `byId` declaration before `setup`, added `teardown: byId.clear()` for defensive test isolation |
| `.github/workflows/ci.yml` | **New** — GitHub Actions: Nim 2.2.x, content generation, build, tools check, all test suites, warning verification |
| `DEV_PLAN.md` | Replaced stale branch-management content with current project snapshot |
| `progress.md` | Converted from empty boilerplate to useful session tracker |
| `STATUS.md` | Updated version, CI info, test count, "what's next" |
| `CHANGELOG.md` | Added v2.1.3 entry |
| `nimlings.nimble` | Version bump 2.1.2 → 2.1.3 |
| `src/nimlings.nim` | Version constant sync 2.1.2 → 2.1.3 |

## Out of Scope (verified non-issues)

- **GC safety warnings** (engine.nim:206,209): Zero with Nim 2.2.10 + ORC GC + `--warning:all`. Not actionable.

## Verification

- [x] `nim check src/nimlings.nim` — clean
- [x] `nim check tools/generator.nim` — clean
- [x] `nimble build` — clean (no warnings)
- [x] `nim c --warning:all src/nimlings.nim 2>&1 | (! grep -i "warning")` — zero warnings
- [x] All test suites pass (Content, Engine, Models, Prerequisites, Solutions)
- [x] 13 new streak tests all pass
- [x] Zero lens_diagnostics errors
