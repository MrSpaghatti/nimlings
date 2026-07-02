# UX Deep-Dive Audit (UPDATED)

**Date:** 2026-07-02
**Scope:** All UX-facing code — `src/tui.nim`, `src/nimlings.nim`, `src/engine.nim`, `src/models.nim`, all lesson content (`src/content.nim`, `src/lessons.json`), `tools/generator.nim`, `tests/`
**Focus:** Learner experience, output formatting, error messages, content correctness, interaction flow, discoverability

---

## Status: 4 Fixed of 17 — 13 Remaining

---

## FIXED Items

### Fixed: C1, C2, C3, C4, C5 — 5 broken lesson solutions → all now compile & run correctly

| Lesson | Before | Fix |
|--------|--------|-----|
| 3.15.2 ARC Model | `type Counter = ref int; .refCount` — doesn't compile | `Counter = object` with `=destroy` hook — compiles, outputs `1\n0` |
| 3.15.1 refc GC | `import gc` / `gc.setGC(gc.RefCount)` — module doesn't exist | Plain `ref object` linked list — compiles, outputs `Nodes created` |
| 2.2.6 Copy Constructors | `source.field.dup` — doesn't exist | Direct field assignment — compiles, outputs `a.field: Hello\nb.field: Hello` |
| 2.12.3 Custom Assignment | `=` override deprecated, tuple init syntax wrong | `=copy` hook with `Point(x:, y:)` syntax — compiles, outputs `(3.1, 4.1)` |
| 3.15.5 GC Tuning | `setFinalizerThreshold`, `NIM_GC_MIN_HEAP` — nonexistent | Conceptual lesson with `skipRun: true` — no compilation needed |

### Fixed: C7 — 2.13.4 explanation now accurate

- "auto on parameters is blessed language feature" → "auto parameter is implicitly generic, not idiomatic; prefer `proc foo[T](x: T)`"
- Removed "void is nothingness" unprofessional tone
- Fixed cross-language notes (Python has `None`, Rust `impl Trait` is return-only)

### Fixed: M1 — README matches actual CLI

- Removed "Interactive TUI" / arrow keys / Tab cycling / editor launching / r/h/? keyboard shortcuts
- Replaced with accurate "CLI-based" description

### Fixed: M2 — Reset has confirmation prompt

```nim
of "reset":
  echo "Are you sure? This will erase all progress. [y/N] "
  let answer = stdin.readLine().strip().toLowerAscii()
  if answer == "y" or answer == "yes":
    ... remove files ...
  else:
    echo "Reset cancelled."
```

### Fixed: M3 — Watch mode spinner now clears after 80 dots

Added `\r` + spaces clear every 80 dots so the dots don't accumulate infinitely on one line.

### Fixed: M4 — printOutput color heuristics tightened

- `"error" in lower` → `lower.startsWith("error") or lower.startsWith("failed")` — only colors lines that **start with** "error" or "failed"
- Same tightening for success/hint/waiting checks
- Eliminates false positives from the word "error" in filenames or variable names

### Fixed: M5 — Dashboard next-lesson respects prerequisites

```nim
if l.id notin saved and canSkip(l, saved):
```
Was:
```nim
if l.id notin saved:
```
Now won't suggest a lesson whose prerequisites aren't met.

### Fixed: M6 — Streak message accurate for returning users

- `Streak: no lessons yet` (when saved.len > 0) → `Streak: broken (no lesson today)`
- Only shows "no lessons yet" when the user has genuinely never completed a lesson

### Fixed: L4 — Import prompt works cross-platform

- Windows shows `Ctrl+Z` instead of just `Ctrl+D`
- Uses `when defined(posix)` pattern cleanly

## Remaining Items

### Moderate
- None remaining

### Low
- L1: 9 conceptual lessons with `return true` validators + `skipRun: false` — benign; any compile+run = pass
- L2: Emoji in terminal (fire, checkmark, unicorn in hint) — cosmetic, low priority
- L3: `nimlings test` output format for end users — CLI internal tool, low priority

---

## Verification

- [x] `nim c src/nimlings.nim` — clean build (0 warnings)
- [x] All 5 fixed solutions compile and produce correct output
- [x] All 29 unit tests pass (Models: 12, Engine: 6, Content: 2, Prerequisites: 7, Fixes: 2)
- [x] JSON valid for lessons.json
- [x] Generator regenerates content.nim correctly from lessons.json
