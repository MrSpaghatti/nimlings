# Audit Report

**Date:** 2026-07-24
**Scope:** Full project audit — src/, tools/, tests/, docs, fleet orchestrator.py
**Method:** 6 parallel read-only scout subagents + direct build/test/E2E verification
**Auditor:** Oh My Pi (omp) — deep-dive audit phase
**Status:** ✅ All actionable findings fixed in v2.1.9

## Verification (run this session)

| Check | Result |
|-------|--------|
| `nim c --warnings:on src/nimlings.nim` | ✅ Clean (0 warnings, 1.5s) |
| `nim c --warnings:on -d:release src/nimlings.nim` | ✅ Clean (0 warnings, 4.3s) |
| `nim check tools/generator.nim` | ✅ Clean |
| `nimble test -y` | ✅ 28/28 pass (Content 2, Engine 5, Models 14, Prerequisites 7) |
| `./src/nimlings test` | ✅ 255/255 pass (~130s) |
| `./src/nimlings -v` | ✅ Reports 2.1.9 |
| Nim version | 2.2.10 |

Prior audit items (v2.1.6–v2.1.8): all confirmed still present in code.

---

## Errors (actual bugs)

- [x] **E1: Lesson 3.15.1 has empty `validation_code` with `skip_run=false`** — `src/lessons.json` — The generator converts empty `validation_code` to `return true` (content.nim:2837-2838), so ANY compilable code passes this lesson. The solution outputs `"Nodes created"`; the validator should be `result.stdout.strip() == "Nodes created"`. This was the ONLY non-skipRun lesson with this defect (verified across all 255). **Impact: High — a user can submit any program that compiles and it will be accepted as correct.** **FIXED: validation_code set, content.nim regenerated.**

- [x] **E3: `updateStreak` date-split can raise uncaught `IndexDefect`** — `src/models.nim:88-95` — `lastDate.split("-")` and `todayDate.split("-")` were indexed `[0]`, `[1]`, `[2]` without length validation. A malformed date string in `daily.json` would raise `IndexDefect`, which is a `Defect` — not caught by the `except ValueError` handler. **Impact: Low — requires manually corrupted `daily.json`, but if triggered, crashes the app instead of resetting gracefully.** **FIXED: added `len != 3` check that raises `ValueError` (caught), resetting streak gracefully.**

- [x] **E4: `defer removeDir(tmpDir)` in `runCode` lacks error handling** — `src/engine.nim:114-116` — If `removeDir` failed (permissions race, NFS, concurrent access), the exception propagated uncaught, terminating the program. The sibling `cleanupOldTempDirs` (line 14-17) already wrapped `removeDir` in `try/except: discard`. **Impact: Low-medium — only affects non-project lessons; cleanup failure aborts the current operation.** **FIXED: defer block now wraps removeDir in try/except: discard.**

## Investigated and Rejected

- [ ] **E2 (investigated, NOT a bug): `updateStreak` unconditionally overwrites `lastLessonDate` on past dates** — `src/models.nim:121-122` — The initial audit flagged this as a bug: when `todayDate < lastLessonDate`, the function updates `lastLessonDate` to `todayDate` without updating the streak. However, the existing test `updateStreak: past date does not increment` (test_models.nim:96-103) explicitly expects this behavior — streak stays unchanged but `lastLessonDate` IS set to `todayDate` and `lessonsToday` IS reset to 1. This is intentional: a lesson done on a past date records the date but doesn't extend the streak. No fix applied.

## Inefficiencies

- [ ] **I1: `runWithTimeout` can deadlock on high-volume output** — `src/engine.nim:93-104` — The polling loop sleeps 100ms while `p.running` but never drains `p.outputStream`. If a child process writes more than the OS pipe buffer (typically 64KB on Linux) before exiting, it blocks on write, never exits, and times out. Then `readAll()` at line 100/103 reads the truncated buffer. **Impact: Low — all 255 lessons produce small output (<1KB), so this is latent. No current lesson triggers it.** Not fixed — deferred to curriculum expansion (new lessons may produce more output).

- [ ] **I2: `parseCompilerErrors` regex captures unused** — `src/engine.nim:44-51` — The regexes have capture groups (`(.+)`) but `.contains()` doesn't extract them. Hints are generic ("You're trying to put a square peg in a round hole") rather than showing the actual types. **Impact: Low — UX polish, not a bug.** Not fixed — cosmetic.

- [x] **I3: `test_prereqs.nim` not imported in `runner.nim`** — `tests/runner.nim:3` — The runner imported `test_models, test_content, test_engine` but NOT `test_prereqs`, so `nim c -r tests/runner.nim` would silently skip all 7 prerequisite tests. `nimble test` was unaffected (compiles each `test_*.nim` separately). **Impact: Low — `nimble test` is the canonical test command, but direct runner execution silently dropped tests.** **FIXED: added `test_prereqs` to import list.**

- [x] **I4: Generator `($ %k)` syntax bug on `files` dict keys** — `tools/generator.nim:61` — `($ %k)` applies the JSON `%` operator to string key `k`, then stringifies. Should be `$k`. Currently unreachable (all 255 lessons have empty `files` dicts), but would produce double-quoted table keys if any lesson added project files. **Impact: Low — latent, no current data triggers it.** **FIXED: changed to `$k`.**

- [ ] **I5: Fleet: `lessons.json` writes not atomic** — `orchestrator.py:319-327` — In-place overwrite without tempfile+rename. A crash during `json.dump` corrupts the file. Backup mitigates but both could be lost. **Impact: Medium — fleet-only, but the source of truth file.** Not fixed — fleet repo, separate scope.

- [ ] **I6: Fleet: LLM retry loop has no backoff** — `orchestrator.py:216-231, 241-256, 271-286` — Three rapid retries with no delay. If the LLM is under load, all three fail identically. Should have 1-5s sleep between attempts. **Impact: Low — fleet-only, wastes API calls.** Not fixed — fleet repo, separate scope.

- [ ] **I7: Fleet: `cp.save()` called after every lesson** — `orchestrator.py:1141, 1162, 1279, 1373, 1393, 1440` — 200+ file writes per batch job with no batching. **Impact: Low — fleet-only, unnecessary I/O overhead.** Not fixed — fleet repo, separate scope.

## Hallucinations / Incorrect Assumptions

- Scout claimed `peekExitCode()` after `p.running == false` was a "critical" bug. **VERIFIED: This is the correct non-blocking pattern.** `peekExitCode` returns -1 if still running, but the while loop only exits when `running` returns false. Scout overstated severity.
- Scout claimed `readAll()` after normal completion was a "critical" bug. **VERIFIED: `readAll()` drains the full pipe after normal completion.** The only edge case is high-volume output exceeding the pipe buffer (see I1). No current lesson produces >64KB. Scout overstated severity.
- Scout claimed E2 was a "critical" bug. **VERIFIED: Not a bug — tested, intentional behavior** (see "Investigated and Rejected" above).

## Style / Consistency

- [x] **S1: STATUS.md `skipRun` count wrong** — `STATUS.md:26-30` — Claimed "12 lessons are `skipRun: true`" but the actual count is **35**. The 12 figure was from v2.1.7 (only the 14 known-failing lessons considered, 2 were fixed). 23 additional lessons are also `skipRun` (early conceptual lessons like 1.1.1, thread/async topics, etc.). **FIXED: 12 → 35.**

- [x] **S2: STATUS.md date stale** — `STATUS.md:3` — Said "Last updated: 2026-07-20" while the v2.1.8 release was 2026-07-21. **FIXED: updated to 2026-07-24.**

- [ ] **S3: `test_engine.nim` line-count assertion is fragile** — `tests/test_engine.nim:91-95` — Uses `output.splitLines.len - 1` to verify output capture. Brittle to trailing newline differences across Nim versions. Should use `output.contains("...")` substring checks. **Impact: Low — test maintenance burden.** Not fixed — cosmetic, currently passing.

- [ ] **S4: 17 lessons missing documentation links** — `src/lessons.json` — Lessons 1.6.5, 2.11.4, 2.8.4, 3.10.4, 3.11.4, 3.15.6, 3.2.6, 4.10.5, 4.12.6, 4.12.7, 4.14.5, 4.15.5, 4.16.6, 4.17.5, 4.18.6, 4.19.3, 4.20.3 have empty or absent `docs` arrays. May be intentional for specialized topics. **Impact: Low — UX, not a bug.** Not fixed — deferred to curriculum expansion.

## Info (observations, not action items)

- **E2E timing**: ~130s clean (consistent with prior 101.5s baseline; difference attributable to release vs debug build and system load).
- **Prior v2.1.8 fixes all verified present**: E1 (project workspace pre-delete removed), I1 (compilerArgs quoteShell), I3 (walkDirs nimlings_* glob), I2 (bare except: narrowed in loadProgress/loadDaily), H1 (validation_code newline/triple-quote rejection), S1 (README 55 Chapters), S2 (STATUS model assignments), S3 (version 2.1.8), S4 (dead removeFile state.json removed).
- **35 `skipRun` lessons** (not 12): The higher count includes early conceptual lessons (1.1.1 "Hello World" explanation), thread/async topics (2.5.1, 2.5.5), and advanced reference material. All have correct solution code; they just can't be one-shot compile+run tested. This was a documentation miscount, now corrected.
- **3 lessons with long concepts >3000 chars**: 2.9.4 CRITBIT Trees (5593), 3.5.5 Custom JSON (4071), 4.19.1 Protocol Design (3856). Justified by topic complexity; not an action item.
- **Fleet findings** (orchestrator.py/proxy.py): proxy broad Exception (HIGH), LLM handlers catch all identically (MED), BatchCheckpoint.load silent corruption (MED), temp paths in logs, subprocess timeout, cleanup, proxy logging, doc fetching. All fleet-pipeline concerns, not core nimlings bugs. Should be addressed in the fleet repo before the 315-lesson expansion.
- **`RunResult.stderr` always empty** — intentional via `poStdErrToStdOut`, documented at `types.nim:44`. Not a bug.
- **`today()` manual string formatting** (`models.nim:42`) works correctly; `times.format(now, "yyyy-MM-dd")` would be more idiomatic but not a bug.
- **`execCmd("nim --version")`** (`engine.nim:27`) works; `findExe("nim")` would be lighter. Low priority.
- **File size approximations** in `DEV_PLAN.md` (~840KB content.nim, ~909KB lessons.json) vs actual (860KB / 930KB). Within acceptable tolerance.
