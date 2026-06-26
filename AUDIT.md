# Audit Report

**Date:** 2026-06-26
**Scope:** Full project audit — all `.nim` source files, tests, generator

---

## Status: ✅ All Prior Findings Resolved, New Findings Below

Previous audit (2026-06-14, v2.1.2) had 16 findings — all fixed. This audit found no actual bugs.

---

### Errors (actual bugs)

**None found.** Code is correct and well-tested.

---

### Inefficiencies

#### [I1] Redundant `import tables` in `engine.nim` — `engine.nim`
`tables` is imported directly but never used in `engine.nim` code. The `Table` type comes through `types.nim` (which imports `tables`). Removing it has no effect.

#### [I2] Dead test "State JSON round-trip" — `tests/test_models.nim`
This test checks that `%* {"last_lesson": "1.2"}` round-trips through Nim's json module. It doesn't test any project-specific code. The `State` type and `saveState`/`loadState` were removed in the v2.1.2 audit but this test was left behind.

#### [I3] Useless conditional in `printDashboard` — `src/tui.nim:53`
```nim
let fire = if daily.streak >= 7: "🔥" elif daily.streak >= 3: "🔥" else: "🔥"
```
All three branches return `"🔥"` — the conditional does nothing. Copy-paste artifact from a planned multi-tier emoji that was never wired in.

---

### Hallucinations / Incorrect Assumptions

**None found.** All API calls, module imports, and stdlib usage are correct. Generated `content.nim` patterns match what `engine.nim` produces.

---

### Style / Consistency

#### [S1] Content test only validates 4 of 8 critical fields — `tests/test_content.nim`
`test "Lesson Fields Integrity"` checks `id`, `name`, `filename`, and `validate`. Doesn't verify `conceptText`, `task`, `solution`, `hint`, or `difficulty` are non-empty. A lesson with empty `task` or `hint` would silently degrade UX.

#### [S2] Manual date arithmetic in `updateStreak` — `src/models.nim:57-90`
~30 lines of manual year/month/day boundary logic for streak calculation. Nim's `times` module supports `parse(lastLessonDate, "yyyy-MM-dd")` and `inDays` diff, which would handle month/year boundaries automatically.

---

### Info (observations, not action items)

- **Build:** Compiles cleanly with `--warning:all` on Nim 2.2, zero warnings
- **Tests:** All 5 suites pass; 13 streak date tests provide good coverage
- **CI:** GitHub Actions validates build, tools, tests, and warnings
- **Security:** No hardcoded secrets, no user-influenced shell commands, no path traversal risk (all lesson data is application-controlled)
- **Resource leaks:** `startProcess` has `defer: close()`, `createTempDir` has `defer: removeDir()`, all file I/O uses `readFile`/`writeFile` (auto-handled)
- **Type safety:** No `auto` return types, no unsafe casts, all exported procs typed
- **Performance:** O(n) iteration over 142 lessons in a few code paths — negligible
- **`epochTime()`** in `runWithTimeout` uses wall clock, not monotonic — harmless for 5s CLI timeout
- **Watch mode** uses blocking `sleep(500)` — expected for CLI, Ctrl+C handled by Nim's SIGINT processing
- **Node.js** pre-installed on GitHub Actions `ubuntu-latest` — JS runner tests work in CI
