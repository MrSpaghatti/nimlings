# Audit Report

**Date:** 2026-06-14
**Scope:** Full project audit — all `.nim` source files, tests, generator

---

## Status: ✅ All Findings Resolved (v2.1.2)

See `CHANGE_REPORT.md` for the fix cycle summary.

## Audit Archive

All findings below were fixed in the 2026-06-14 audit fix cycle (4 batches).

---

### Errors (actual bugs)

#### [E1] Version mismatch between nimble and source — src/nimlings.nim ✅
- **Fix:** Synced to `"2.1.2"` (used `staticRead`-compatible manual constant, synced with nimble)

#### [E2] Silent data loss on corrupted progress files — src/models.nim ✅
- **Fix:** Added `stderr.writeLine` warnings on corrupt progress/daily/state files

#### [E3] Inconsistent `findLesson` failure handling — src/nimlings.nim ✅
- **Fix:** `findLessonById` now delegates to `findLesson` instead of duplicating iteration

#### [E4] Fragile `splitLines()[0]` on empty concept text — src/tui.nim ✅
- **Fix:** Added guard: checks `lesson.conceptText.len > 0` before accessing `[0]`

---

### Inefficiencies

#### [I1] `canSkip` re-searches the lesson every call — src/engine.nim ✅
- **Fix:** Added `canSkip(lesson: Lesson, progress: HashSet[string])` overload; callers in `nimlings.nim` and `tui.nim` use it

#### [I2] Nested iteration in `printDashboard` — src/tui.nim
- **Note:** With 120 lessons, negligible. Not modified.

#### [I3] `runWithTimeout` polling loop — src/engine.nim ✅
- **Fix:** Changed `os.sleep(50)` to `os.sleep(100)` (100→50 iterations)

---

### Hallucinations / Incorrect Assumptions

#### [H1] `--d:release` in `nimlings.nims` for dev builds ✅
- **Fix:** Removed `--d:release` flag from `nimlings.nims`

#### [H2] JS mode assumes Node.js is installed — src/engine.nim ✅
- **Fix:** Added `checkNodeInstalled()` proc, called before JS lesson execution

#### [H3] `RunResult.stderr` is never populated ✅
- **Fix:** Added documentation comment to the field in `types.nim`

#### [H4] Generator regex misses non-standard patterns — tools/generator.nim
- **Note:** All 120 lessons use the standard pattern. Not modified.

---

### Style / Consistency

#### [S1] Version drifts from nimble ✅
- **Note:** Kept manual constant approach for simplicity; now synced to `"2.1.2"`

#### [S2] Hungarian-ish regex naming — src/engine.nim ✅
- **Fix:** Renamed to `typeMismatchRe`, `undeclaredRe`, `indentErrorRe`

#### [S3] 42 `echo` calls in `printHelp()` — src/nimlings.nim ✅
- **Fix:** Single `echo` with triple-quoted multi-line string

#### [S4] Unused `tables` import in generator — tools/generator.nim ✅
- **Fix:** Removed import

#### [S5] Unused `Progress` type — src/models.nim ✅
- **Fix:** Removed type

#### [S6] Uncalled `saveState`/`loadState` — src/models.nim ✅
- **Fix:** Removed both procs and `StateFile` constant

---

## Info (observations, not action items)

- **GC safety warnings** in `engine.nim:206,209` — harmless with ORC GC
- **`test_prereqs.nim`** fragile test isolation — deterministic but not defensive
- **`recordLessonCompletion`** date logic verbose but correct (~60 lines manual date arithmetic)
- Compilation fast (~0.5s check, ~1s full build)
- **No linter/formatter** in CI — `nimpretty` mentioned in docs but not enforced
