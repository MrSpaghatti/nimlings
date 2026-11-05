# Change Report

**Date:** 2026-07-24
**Version:** 2.1.9
**Type:** Deep-dive audit fixes (second cycle)

## Summary

Ran a second full deep-dive audit of the nimlings project via 6 parallel read-only scout subagents (engine/types, models/CLI, tui/generator/tests, lessons.json structure, fleet orchestrator, doc consistency) plus direct build/test/E2E verification. Found 1 critical bug (lesson 3.15.1 empty `validation_code` with `skip_run: false` — any compilable code passed), 2 low-severity robustness bugs, and several consistency/doc items. All actionable findings fixed; build clean, 28/28 unit tests pass, 255/255 E2E pass.

## Files Modified

| File | Changes |
|------|---------|
| `src/lessons.json` | E1: lesson 3.15.1 `validation_code` `""` → `result.stdout.strip() == "Nodes created"`. The empty validator caused the generator to emit `return true`, accepting any compilable code. |
| `src/content.nim` | Regenerated from `lessons.json` via `nimble generate_content`. `validate_3_15_1` now checks `output.strip() == "Nodes created"`. |
| `src/models.nim` | E3: Added `len != 3` check before date-split array access in `updateStreak`. Malformed dates now raise `ValueError` (caught) instead of `IndexDefect` (uncaught `Defect` that crashes the app). |
| `src/engine.nim` | E4: `defer removeDir(tmpDir)` wrapped in `try/except: discard` for consistency with `cleanupOldTempDirs`. |
| `tests/runner.nim` | I3: Added `test_prereqs` to import list so `nim c -r tests/runner.nim` runs all 4 suites. |
| `tests/test_models.nim` | Added 2 regression tests for E3: malformed `lastLessonDate` and malformed `todayDate` don't crash. |
| `tools/generator.nim` | I4: `($ %k)` → `$k` for `files` dict keys (JSON stringify → plain stringify). Unreachable currently. |
| `src/nimlings.nim` | Version constant 2.1.8 → 2.1.9. |
| `nimlings.nimble` | Version 2.1.8 → 2.1.9. |
| `STATUS.md` | S1: `skipRun` count 12 → 35. S2: date 2026-07-20 → 2026-07-24. |
| `CHANGELOG.md` | Added [2.1.9] entry. |
| `AUDIT.md` | Full audit report rewritten for this cycle. |

## Key Decisions

- **E2 ("past-date overwrites lastLessonDate") investigated and rejected as a bug**: The existing test "updateStreak: past date does not increment" (test_models.nim:96-103) explicitly expects `lastLessonDate` to be updated to `todayDate` even when `todayDate < lastDate`. This is intentional: the streak doesn't increment, but the date and `lessonsToday` are updated. The initial audit report flagged this as a bug; source verification against the test suite proved it is tested, intended behavior. No fix applied.
- **E1 is the single critical fix**: The only non-`skipRun` lesson with empty `validation_code` across all 255 lessons. The generator's `return true` default meant ANY compilable code passed. Fix is a one-line JSON change + regeneration.
- **E3 adds length validation, not type validation**: The fix checks `len != 3` and raises `ValueError` (already caught by the existing handler). This converts an uncaught `IndexDefect` crash into a graceful streak reset. It does NOT validate the date is real (e.g., "2026-99-99" still passes) — `parseInt` handles numeric validity.
- **E4 matches existing pattern**: `cleanupOldTempDirs` (engine.nim:14-17) already wraps `removeDir` in `try/except: discard` for permissions races. The `defer` block in `runCode` now matches.

## Verification

- [x] `nim c --warnings:on src/nimlings.nim` — zero warnings (1.5s)
- [x] `nim c --warnings:on -d:release src/nimlings.nim` — zero warnings (4.3s)
- [x] `nim check tools/generator.nim` — clean
- [x] `nimble generate_content` — clean
- [x] `nimble test -y` — all 28 tests pass (Content 2, Engine 5, Models 14, Prerequisites 7)
- [x] `./src/nimlings test` — all 255 lessons pass (100%, ~130s)
- [x] `./src/nimlings -v` — reports 2.1.9

## Next Session Should

1. Launch Phase 2 of the curriculum expansion: start the local fleet (`~/nimlings-fleet/fleet-nimlings.sh start`), ensure `OPENROUTER_API_KEY` is set, and run `python3 orchestrator.py --continuous --max-hours 24` to generate the 60 new lessons toward the 315-lesson target.
2. Monitor `~/nimlings-fleet/logs/` for smith failures and fix-loop behavior under the new local fixer/auditor.
3. After generation: `nimble generate_content`, then `nim c --warnings:on src/nimlings.nim`, `nimble test -y`, `./nimlings test` — target 315/315.
4. Adapt prerequisite tests for the new Level 5 structure (new chapters shift the level-gate assertions).
5. Update STATUS.md/CHANGELOG.md to v2.2.0 upon successful 315-lesson verification.
6. Fleet-only findings (non-atomic `lessons.json` writes, no retry backoff, per-lesson save) should be addressed in the fleet repo before relying on it for the 315-lesson expansion.
