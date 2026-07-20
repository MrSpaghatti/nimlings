# nimlings Status

**Last updated:** 2026-07-19

## Project Overview

Interactive Nim tutor — 255 lessons across 4 levels. CLI application in 100% Nim.
LLM-driven lesson generation pipeline at `~/nimlings-fleet/` with hybrid backend:
- **Planner/Auditor/Fixer:** Google Gemini 2.5 Flash (OpenRouter) — planning, auditing, fixes
- **Smith (generation):** Qwen3.6-27B (local, Q4_K_M, R9700/ROCm) — bulk generation, fixes

## Current Status: 255/255 Lessons — 241/255 (94.5%) Verified End-to-End

| Metric | Value |
|--------|-------|
| Lessons | 255 — comprehensive Nim curriculum |
| Build | Compiles cleanly, zero warnings (`nim c --warnings:on src/nimlings.nim`) |
| Unit tests | All 5 suites pass (Content, Engine, Models, Prerequisites) |
| `nimlings test` (runs every solution against its validator) | **241/255 passing** |
| Curriculum tree | 255 topics across 4 levels, 55 chapters |
| Local model | Qwen3.6-27B (dense, 17GB Q4_K_M, ~32GB VRAM) |
| OpenRouter model | Gemini 2.5 Flash ($0.15/$0.60 per MTok) |

## 2026-07-19 Session: Deep Content & Engine Audit

Previous sessions claimed "clean build, all tests pass" — true, but misleading: `src/content.nim`
(generated from `lessons.json`, gitignored) was stale and hadn't been regenerated in a while, so the
build was validating old content, not what was actually in `lessons.json`. Regenerating it surfaced
the real state of the curriculum. Ran `nimlings test` (compiles + runs every lesson's own solution
against its own validator — the actual end-to-end check) and worked through the failures.

**Before this session:** untested — build "passed" against stale content.
**After this session:** 241/255 lessons verified to actually compile, run, and pass their own validator.

### What was actually broken

- **Fictitious APIs invented wholesale**: `import std/exit`, `import result` (should be `results`),
  `RwLock`/`newRwLock` (doesn't exist — real thread-safe patterns use `std/locks` or `std/sharedtables`),
  a fabricated `nimyaml` library, `nkIntTy`/`ntyInt` type-kind constants that don't exist,
  `NimNode.walk` (no such proc), `dumpTree(x)` misused on an already-bound `NimNode`, `.dup` on strings,
  `envExists` (real name: `existsEnv`), `runTests()` (doesn't exist — `unittest` runs tests automatically),
  `SdlFalse`/`SDL_CreateWindow`/`SDL_GetError` (the `sdl2` Nim wrapper drops the `SDL_` prefix and uses
  camelCase), `std/io`, `std/mem`, `std/thread`, `std/sync/channels`, `netaddress`, `sysrand.randInt`.
- **Modules that moved out of the standard library**: `db_sqlite` and friends are now the separate
  `db_connector` nimble package; `md5`/`sha1`/`htmlparser` are deprecated in favor of `checksums`/`pkg/*`
  but still work with a warning.
- **Validators that redefined a hardcoded reference solution and tested *that*** instead of the
  student's actual code/output — meaning they'd pass regardless of what the student wrote. Rewritten to
  check the real captured `output`/`exitCode`.
- **Engine bug**: `nim c -r` compiler warnings (e.g. unused imports) were captured into the same stdout
  stream as the program's own output, breaking exact-match validators. Fixed by compiling lesson
  solutions with `--warnings:off`.
- **Engine bug**: `validate()` unconditionally treated a non-zero exit code as failure *before* calling
  the lesson's own validator — making it structurally impossible for a lesson to correctly test "this
  should fail to compile" (effect-system violations) or "this should crash" (uncaught `Defect`). Fixed
  so the lesson's own validator always gets the final say.
- **No stdin support**: lessons using `readLine(stdin)` had nothing feeding their stdin, so they'd hang
  until the 5s timeout. Added real stdin piping (`Lesson.stdinInput`, a `"stdin"` field in `lessons.json`,
  wired through `runWithTimeout`).
- **`src/lessons.json.bak` / `.bak.testcycle`**: stray backup files from a prior editing session, removed
  (now gitignored via `*.bak*`).

### Known-remaining failures (14 of 255 — genuinely structural, not quick fixes)

These don't fit the "compile one `.nim` file, run it, check stdout" execution model, or need
infrastructure this repo doesn't have:

- **3.15.3** — custom container with `=trace`/`=destroy` hooks; substantial manual-memory-management example, needs a careful rewrite.
- **4.10.4** — UDP multicast networking (binds real sockets; flaky/order-dependent under a 5s timeout).
- **4.10.5** — references a fictitious `websocket/websocket` package.
- **4.12.5** — SDL2 game loop with hot-code-reload; needs a real window/event loop, not a one-shot script.
- **4.13.3** — inline GCC-style assembly; syntax is finicky and architecture-specific.
- **4.15.3** — references a fictitious `fidget` GUI library.
- **4.17.5** — JWT/HMAC implementation; likely has further API-correctness issues, not yet fully audited.
- **4.19.1, 4.19.2, 4.19.3** — async TCP chat/broadcast servers that `bindAddr` and loop forever; don't fit a one-shot "run and capture stdout" model at all.
- **4.20.1** — `enumerate` for-loop macro; needs Nim's special for-loop-macro mechanism (`{.forLoop.}` / a `ForLoopStmt` typed parameter), not a generic `NimNode` macro.
- **4.20.3** — hooks into `compiler/ast`, `compiler/msgs`, `compiler/plugins` (Nim compiler internals); largely fictional/version-specific API usage, would need a from-scratch rewrite against the real compiler API.
- **4.3.5** — Nim-compiled-to-shared-library linked from a separate C++ program; needs a real two-step build the engine doesn't support.
- **4.3.6** — Objective-C/`NSLog` interop; macOS-only, untestable in this Linux environment.

## What's Here

- ✅ 255 lessons across 4 levels
- ✅ Hybrid LLM pipeline: OpenRouter for planning, Qwen3.6-27B local for generation
- ✅ 255-topic comprehensive Nim curriculum tree covering every language feature
- ✅ Full pipeline: planner → smith → validate → fix → inject → build → test
- ✅ Orphaned `/tmp/nimlings_*` cleanup on startup
- ✅ Real stdin support for lessons that read user input
- ✅ `nimlings test` — the real end-to-end check (compiles+runs every solution, validates output);
  regenerate `src/content.nim` first (`nimble generate_content`) if you've edited `lessons.json` directly

## Architecture

```
~/nimlings-fleet/
├── fleet-nimlings.sh     # Start/stop Qwen3.6-27B + proxy
├── orchestrator.py        # Main generation loop
├── run-24h.sh             # 24-hour batch run script
├── nimdocs/               # Documentation retrieval module
│   └── __init__.py        # Index builder & keyword retriever
├── nim-topics.json        # 255-topic comprehensive curriculum
├── proxy.py               # OpenAI-compatible API proxy
└── logs/                  # Session logs
    └── reports/           # Run reports
```

## Usage

```bash
cd ~/nimlings-fleet

# 1. Start the fleet
./fleet-nimlings.sh start

# 2. Check coverage
python3 orchestrator.py --audit-only

# 3. Generate one lesson
python3 orchestrator.py --topic "4.12.6"

# 4. Continuous mode
python3 orchestrator.py --continuous --max-hours 24

# 5. Run full audit
python3 orchestrator.py --audit-content

# 6. Rebuild doc index (after Nim update)
python3 orchestrator.py --rebuild-index
```

In the main repo:

```bash
nimble generate_content   # regenerate src/content.nim from src/lessons.json
nim c src/nimlings.nim    # build
./nimlings test           # run every lesson's solution against its validator (the real check)
nimble test                # run the unit test suites
```
