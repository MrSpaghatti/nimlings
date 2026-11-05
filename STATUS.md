# nimlings Status

**Last updated:** 2026-11-05

Interactive Nim tutor — 255 lessons across 4 levels and 55 chapters, CLI in Nim.
This file is the single source of **current state and open work**. History lives in
[`CHANGELOG.md`](CHANGELOG.md); superseded plans and audits live in
[`docs/archive/`](docs/archive/).

## Current state (verified 2026-11-05)

| Check | Result |
|---|---|
| Build | `nimble build` clean — v2.1.10 |
| Unit tests | **29/29** across 4 suites (Models 14, Content 2, Engine 6, Prerequisites 7) |
| `nimlings test` | **255/255** — of which **220 are executed end-to-end** and **35 are structure-validated** `skip_run` reference lessons |
| Lessons | 255 across 4 levels (34 / 61 / 66 / 94), 55 chapters |
| License | MIT — [`LICENSE`](LICENSE) |
| CI | `.github/workflows/ci.yml` |

## 2026-11-05 session: the build was broken, and now it isn't

**The repo did not compile at HEAD.** `nimble build` failed with:

```
src/content.nim(1726, 13) Error: undeclared identifier: 'helpers'
```

Root cause: `tools/generator.nim` emitted `files` table keys with `$k`. In `std/json`,
`pairs` yields `(string, JsonNode)`, so `$k` on the key is a plain string and is emitted
**unquoted** — producing `files: {helpers.nim: "..."}`, which is not valid Nim. **13
lessons** have non-empty `files` tables, so all of them broke the build.

This was introduced by the v2.1.9 fix for audit item I4, which changed `($ %k)` → `$k`
believing the JSON quoting was the bug. The quoting *was* the fix. The audit also recorded
the path as "unreachable (all 255 lessons have empty `files` dicts)" — 13 don't. Fixed by
using `escape(k)`.

Also fixed this session:

- **I1 — `runWithTimeout` deadlock.** The poll loop never drained the child's pipe, so a
  child writing more than the 64 KiB pipe buffer blocked in `write()`, never exited, and
  was reported as an infinite loop. Output now goes to a **file** instead of a pipe.
  Regression test added (writes ~400 KiB).
- **`cleanupOldTempDirs` deleted live temp dirs.** It removed every `/tmp/nimlings_*` at
  startup, so a second `nimlings` invocation — even `nimlings list` from a shell prompt —
  destroyed the directory a running lesson was compiling in. That surfaces as a bogus
  "COMPILE/RUN ERROR" with empty output and is very hard to attribute. Now only removes
  dirs untouched for 10 minutes.
- **Stale binary.** The checked-out `nimlings` binary was **v2.1.3 from 2026-06-29** and
  reported "2/144 lessons". Rebuilt; it now reports 2/255.
- **LICENSE added (MIT).** The README claimed MIT but no license file existed, so the
  published repo was legally unusable.
- **11 committed `.pyc` files untracked** (`__pycache__/`, `src/__pycache__/`) — leftovers
  from the pre-Nim Python implementation, committed despite `.gitignore` listing them.
- **Docs consolidated.** `PLAN.md`, `DEV_PLAN.md`, `AUDIT.md`, `CHANGE_REPORT.md` moved to
  `docs/archive/`. This file is now the only current-state doc.

## Open items

| # | Item | Severity |
|---|---|---|
| I2 | `parseCompilerErrors` regexes capture groups but `.contains()` discards them, so hints stay generic instead of naming the actual types | Low (UX) |
| S3 | `test_engine.nim` line-count assertion is brittle across Nim versions | Low |
| S4 | 17 lessons have empty `docs` arrays | Low (UX) |
| — | 35 `skip_run` lessons are structure-validated only; a human pass over their prose and idioms would help most | Medium |
| — | `tools/add_docs.py` is Python in an otherwise-Nim project | Low |
| — | No demo GIF / asciinema in the README (a real `nimlings list` transcript is there instead) | Low |

Fleet-side items (I5–I7: non-atomic `lessons.json` writes, no retry backoff, per-lesson
checkpoint saves) belong to `~/Projects/nimlings-fleet`, not this repo.

## Content is frozen at 255

The 255 → 315 expansion plan in `docs/archive/PLAN.md` was never executed and is not
planned. The open problem is **consumption, not content**: two lessons have ever been
completed. More lessons do not move that number.

## Architecture

The tutor is self-contained; the *generation* pipeline that produced the lessons is a
separate repo.

```
~/Projects/nimlings/            this repo — the tutor
├── src/                        engine, TUI, models, generated content
├── tools/generator.nim         lessons.json -> content.nim
├── tests/                      4 suites, 29 tests
└── docs/archive/               superseded plans and audits

~/Projects/nimlings-fleet/      the generation pipeline (not needed to use the tutor)
├── fleet-nimlings.sh           attaches to a loaded Radiance mode, writes .fleet-env
├── orchestrator.py             planner -> smith -> validate -> fix -> inject
├── run-24h.sh                  batch run
├── nim-topics.json             255-topic curriculum tree
└── proxy.py                    RETIRED (llama.cpp era) — unused
```

Generation split: **Planner** on OpenRouter (Gemini 2.5 Flash, ~$0.0002/lesson);
**Smith / Fixer / Auditor** on the local Radiance container on the R9700 — bulk token
spend is zero. One card holds one model, and Radiance ignores a request's `model` field,
so the **port** selects the model (`:8300` twin, `:8310` nim, `:8320` fleet).

## Commands

```bash
# this repo
nimble build               # regenerate content.nim + build
nimble test                # 4 unit suites (29 tests)
./nimlings test            # every lesson's solution against its validator
./nimlings list            # dashboard

# the fleet (only if you are generating new lessons)
cd ~/Projects/nimlings-fleet
./fleet-nimlings.sh check  # refuse to run unless the expected model is loaded
./fleet-nimlings.sh start  # attach + write .fleet-env
python3 orchestrator.py --audit-only
```

## Earlier sessions

- **2026-11-05 (backend):** the fleet stopped running its own model server. `fleet-nimlings.sh`
  attaches to the Radiance container and refuses to run blind (`check` gate). `orchestrator.py`
  talks straight to `:8310/v1`; `proxy.py` retired; the dead Qwen3.6-27B GGUF path removed.
  Requests carry `chat_template_kwargs {"enable_thinking": false}` — without it a
  reasoning-tuned base spends the whole token budget on the trace and returns empty content.
  `run-24h.sh` had an unterminated heredoc (`REPORTEOF` at 171 vs `EOF` at 199) that swallowed
  the last 70 lines of the script. `rocm-smi` call sites replaced with `amd-smi` (ROCm 10.1).
- **2026-08-02 (v2.1.10):** `ConfigDir` was a `const`, so `getHomeDir()` was baked in at
  compile time — `reset`/`export` used the runtime value while `loadProgress`/`saveProgress`
  used the build machine's. Now a `let`. `status` counted raw progress-set size instead of
  validating IDs against the lesson tree; `import` accepted any string. Both now validate.
- **2026-07-24 (v2.1.9):** audit cycle — E1 (lesson 3.15.1 accepted any compilable code),
  E3 (`updateStreak` `IndexDefect` on malformed dates), E4 (unguarded `removeDir` in `defer`),
  I3 (`test_prereqs` missing from the runner). See `docs/archive/AUDIT.md`.
- **2026-07-20:** the last 14 known structural failures resolved; 35 lessons marked
  `skip_run` as reference material.
