# Plan: Polish Round — Tests, CI, and Housekeeping

## Goal
Address 5 remaining improvement items from the audit and onboarding:
1. **No test for streak/date logic** — `recordLessonCompletion` has ~60 lines of manual date arithmetic with zero coverage
2. **Fragile test isolation** — `test_prereqs.nim` shares a mutable `byId` table across tests
3. **No CI pipeline** — zero GitHub Actions, no automated build/test on push
4. **Stale DEV_PLAN.md** — references resolved branch conflicts from Nov 2025
5. **Empty progress.md** — boilerplate template, no actual content

## Approach
Smallest viable change for each item. No architectural refactors. Work in dependency order (tests first, then CI, then docs).

## Tasks

### 🟡 Medium
- [ ] **1. Extract + test streak date logic** — `src/models.nim`, `tests/test_models.nim`
  Extract `updateStreak(daily, todayDate)` pure proc from `recordLessonCompletion`.
  Write 6 test cases: first lesson, same day, consecutive day, month boundary, year boundary, gap > 1 day.
  Remove the "no test" observation from the audit.

### 🟢 Small
- [ ] **2. Fix test_prereqs.nim isolation** — `tests/test_prereqs.nim`
  Move `byId` into a helper proc called from each test instead of suite-level `setup`.
  Prevents cross-test contamination if tests are added/modified later.
  Add `teardown: byId.clear()` for belt-and-suspenders.

### 🟡 Medium
- [ ] **3. Add GitHub Actions CI** — `.github/workflows/ci.yml`
  Trigger: push, pull_request to main.
  Steps: checkout, install Nim 2.2.x, nimble build, nimble test.
  Covers `src/`, `tools/`, and all 5 test suites.

### 🟢 Small
- [ ] **4. Update DEV_PLAN.md** — `DEV_PLAN.md`
  Replace stale branch-management content with current status snapshot.
  Add a "What's Here" section and link to STATUS.md for live state.

### 🟢 Small
- [ ] **5. Clean up progress.md** — `progress.md`
  Remove if unused, or fill with actual tracking content if needed.

## Dependencies
- Task 2, 4, 5 are independent — any order
- Task 1 is independent (tests don't touch same files)
- Task 3 is independent (new file)
- Final step: `nim check` all files, run full test suite, verify nothing regressed

## Risks
- **Low:** TDD-style refactor of `recordLessonCompletion` — pure extraction, no behavior change
- **Low:** CI workflow may need tweaks for Nim version paths — easy to fix post-commit
- **Low:** `progress.md` — removing an unused file is risk-free

## Out of Scope (verified non-issues)
- GC safety warnings: `--warning:all` produces zero warnings on Nim 2.2.10 with ORC GC. Not actionable.

## Review Status
- [ ] User approved plan
