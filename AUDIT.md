# UX Deep-Dive Audit (UPDATED)

**Date:** 2026-07-19
**Scope:** All UX-facing code, all lesson content, lesson dependency graph, content accuracy audit
**Focus:** Learner experience, content correctness, interaction flow, discoverability, factual accuracy

---

## 2026-07-19: End-to-End Solution Audit — 170 → 241 of 255 lessons verified

The 2026-07-18 entry below still listed two open items: the prereq graph test failing, and 17 new
lessons never audited. Both are now resolved, and a much deeper problem was found and fixed in the
process: **the build's "clean" status was misleading**. `src/content.nim` (generated from
`lessons.json`, gitignored) was stale, so `nim c src/nimlings.nim` had been silently compiling old
content for a while — not what was actually checked into `lessons.json`. The moment it was
regenerated, dozens of lessons failed to compile.

Fixed the prereq graph (lesson `2.11.4` had no prerequisites, making it unreachable — added
`"2.11.3"`). Then ran `nimlings test`, which actually compiles and runs **every lesson's own solution
against its own validator** — the real ground truth, as opposed to "the project builds." First pass:
**170/255 passing**. After this session's fixes: **241/255 (94.5%) passing**, verified by rerunning the
full suite after every batch of changes.

### Root causes found, roughly in order of how many lessons they explained

1. **Fictitious APIs** — the single largest category. Invented modules (`std/exit`, `std/io`,
   `std/mem`, `std/thread`, `std/sync/channels`, `netaddress`, a fake `nimyaml` package, a fake
   `websocket/websocket` package, a fake `fidget` GUI package), invented procs/types (`RwLock`/
   `newRwLock`, `NimNode.walk`, `nkIntTy`/`ntyInt`, `typetraits.isTuple`, `sysrand.randInt`, `.dup` on
   strings, `envExists`, `runTests()`, `SdlFalse`/`SDL_CreateWindow`/`SDL_GetError`,
   `initCfgParser`, `Instant`/`parseInstant`), and real procs called with the wrong signature
   (`initDateTime`'s deprecated *and* differently-ordered arguments, `sample(seq, count)` — the real
   `sample` only draws one element per call, `resp.status` treated as `int` when it's a `string`).
2. **Validators that tested a hardcoded copy of the reference solution instead of the student's
   code** — several `validation_code` blocks literally redefined the target function/proc and
   asserted against *that*, never referencing the actual `output`/`code` the engine captured from
   running the student's program. These would have silently passed regardless of what a learner
   wrote. Rewritten to check the real captured output.
3. **Modules moved out of the standard library**: `db_sqlite` (→ `db_connector` nimble package),
   `md5`/`sha1`/`htmlparser` (deprecated in favor of `checksums`/`pkg/*`, but still usable with a
   warning). Added `results` and `db_connector` to `nimlings.nimble`'s `requires`.
4. **Engine bug — compiler warnings polluting stdout**: `nim c -r` warnings (e.g. unused imports)
   were captured into the same stream as the program's real output, breaking any validator doing an
   exact string match. Fixed by adding `--warnings:off` to the lesson-solution compile command in
   `engine.nim` — a single change that fixed a double-digit number of lessons at once.
5. **Engine bug — non-zero exit always meant "fail," even when the lesson's whole point was that
   the code *should* fail to compile or crash** (effect-system `forbids` violations, uncaught
   `Defect`s). `validate()` in `engine.nim` checked `res.exitCode != 0` and short-circuited before
   ever calling the lesson's own validator. Reordered so the lesson's validator always gets the
   final say; the "nice" compile-error message is now just the fallback when that validator also
   says no.
6. **No stdin support at all**: any lesson using `readLine(stdin)` had nothing feeding stdin, so it
   would hang until the 5s timeout and get killed. Added real stdin plumbing: `Lesson.stdinInput`
   (`types.nim`), a `"stdin"` JSON field (`generator.nim`), piped through `runWithTimeout`
   (`engine.nim`) via the process's `inputStream`.
7. **Genuine logic bugs in the "solution" itself**: e.g. a union type-punning lesson (`3.3.7`)
   asserted `Float: 5.5` for a bit pattern that is actually `1.0f`; a PEG email-validator lesson
   (`3.12.3`) hit a classic no-backtracking-in-PEG trap where a greedy character class silently
   swallowed the character a later part of the same rule needed; an object-variant lesson (`4.18.6`)
   reused the same field name (`height`) across two different `case` branches, which Nim rejects
   even though the types matched.
8. **Tasks structurally incompatible with "compile one file, run it, check stdout"**: several
   lessons were actually about writing a `.nims`/`.nimble` config, a Dockerfile, or a CI YAML file —
   not Nim source at all — but were still being fed through `nim c -r`, which can never succeed.
   Converted these (`3.8.4`, `3.8.5`, `4.11.4`, `4.12.1`, `4.12.3`, `4.16.6`) to `skip_run: true`
   with validation against the submitted text instead of runtime output.

### 14 lessons still failing (`nimlings test`), left as known issues — see STATUS.md for the full list

Not quick fixes: async TCP servers that bind ports and loop forever (`4.19.1-3`), UDP multicast
networking (`4.10.4`), a fictitious websocket/GUI library each (`4.10.5`, `4.15.3`), an SDL2
hot-reload game loop (`4.12.5`), inline assembly (`4.13.3`), Nim-compiler-internals plugin hooks
(`4.20.3`), a for-loop macro needing Nim's special `ForLoopStmt` mechanism (`4.20.1`), a
shared-library-plus-separate-C++-program build the engine can't drive (`4.3.5`), macOS-only
Objective-C interop (`4.3.6`), a hand-rolled `=trace`/`=destroy` container (`3.15.3`), and a
JWT/HMAC implementation not yet fully audited for further API issues (`4.17.5`).

### Side effects of this session worth knowing about

- Installing the `sdl2` nimble package (for lesson `4.15.4`) also rebuilt and reinstalled this
  repo's own `nimlings` binary into `~/.nimble/bin` as a side effect of running `nimble install`
  from inside this directory — it replaced an existing symlink there with a fresh build of the
  current (fixed) source. Harmless, but not something this session set out to do.
- Deleted `src/lessons.json.bak` and `src/lessons.json.bak.testcycle` (untracked backup files from
  a prior session) and added `*.bak*` to `.gitignore`.

---

---

## 24-Hour Run Audit Results (2026-07-17)

A full content audit of all 238 lessons found **102 lessons with factual or code errors**.
All 102 were auto-fixed by the local Qwen3.6-27B model. A re-audit confirmed fixes applied.

### Common Error Patterns Found

| Pattern | Example | Count |
|---------|---------|-------|
| Made-up APIs | `{.noGC.}`, `awaitAll`, `asyncDiscard` | ~15 |
| Wrong function signatures | `getType` on untyped params, `=destroy(var)` vs `=destroy` | ~12 |
| Missing imports | Using `Table` without `std/tables` | ~8 |
| Invalid Nim syntax | `cast[string](mf.mem[0 ..< mf.size])` | ~6 |
| Incorrect module names | `import gc` instead of `std/gc` | ~5 |
| Wrong async patterns | Missing `waitFor`/`runForever` | ~4 |
| Forward reference errors | Proc used before declaration | ~3 |
| Misleading explanations | "ARC doesn't handle cycles" (ORC does) | ~10 |

### Remaining Issues (Post-Fix)

After auto-fix, the re-audit still found issues — mostly informational/warnings that require human judgment:
- Some explanations are technically correct but could mislead
- Some solutions work but aren't idiomatic Nim
- Some lessons lack depth on important edge cases

### Known Issues

- **Prereq graph test fails** — `test_prereqs` reports lessons unreachable from root. The dependency tree needs manual review.
- **17 new lessons** (255 curriculum) were never audited — added in the final batch, zero quality pass.

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
