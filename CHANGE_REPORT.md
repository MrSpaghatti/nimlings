# Change Report

**Date:** 2026-06-14
**Type:** Full audit fix cycle — bugs, inefficiencies, style cleanup

## Summary

Executed the full fix plan from AUDIT.md across 4 batches. All 16+ audit findings resolved across 7 source files. Version bumped to 2.1.2.

## Files Modified

| File | Changes |
|------|---------|
| `src/nimlings.nim` | Version sync (2.0.0→2.1.2), `printHelp` multi-line string, `findLessonById` delegates to `findLesson`, `canSkip` callers use lesson object overload |
| `src/nimlings.nims` | Removed `--d:release` flag (stack traces in dev builds) |
| `src/models.nim` | Added stderr warnings on corrupt progress/daily load, removed dead `Progress` type, `saveState`/`loadState` procs, `StateFile` constant |
| `src/engine.nim` | Regex naming (`Re*`→`*Re`), added `checkNodeInstalled()`, Node.js check in JS mode, `canSkip(lesson, progress)` overload, polling 50ms→100ms |
| `src/tui.nim` | Defensive guard on empty `conceptText` in `printLessonHeader`, `canSkip` uses lesson object |
| `src/types.nim` | Added comment on empty `stderr` field |
| `tools/generator.nim` | Removed unused `tables` import, removed unused `chapId`/`chapName`/`levelName` vars |
| `CHANGELOG.md` | Added v2.1.2 entry |
| `STATUS.md` | Updated to reflect audit clearance |

## Verification

- [x] `nim check src/nimlings.nim` — clean
- [x] `nim check tools/generator.nim` — clean
- [x] `nimble build` — clean (no warnings)
- [x] All 4 test suites pass (Content, Engine, Models, Prerequisites)
- [x] Zero lens_diagnostics errors
