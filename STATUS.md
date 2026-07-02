# nimlings Status

**Last updated:** 2026-07-01 (LLM-driven lesson generation session)
## Project Overview

Interactive Nim tutor — 238 lessons across 4 levels. CLI application written in 100% Nim.
LLM-driven lesson generation pipeline at `~/nimlings-fleet/` for automated curriculum coverage.

## Current Status: ✅ Complete — 238/238 Lessons
- **Version:** 2.1.5-dev (source: 2.1.3)
- **Build:** Compiles cleanly (zero warnings with `--warning:all`)
- **Tests:** All pass (Content, Engine, Models, Prerequisites) — 238 lessons, 5 suites
- **CI:** GitHub Actions workflow at `.github/workflows/ci.yml`
- **Lessons:** 238 ✅ — 94 new LLM-generated, curriculum fully covered
## What's Here

- ✅ 238 lessons across 4 levels (was 144) — full 238-topic curriculum
- ✅ LLM-driven lesson generation pipeline at `~/nimlings-fleet/`
- ✅ Local LLM fleet: Qwen2.5-Coder-14B on R9700 (ROCm) ~8 tok/s
- ✅ 238-topic comprehensive Nim curriculum tree (nim-topics.json) covering every language feature
- ✅ Gap auditor — tracks coverage (currently 144/238 = 60.5%)
- ✅ Nim documentation index — 546 sections from 14 official docs files for LLM grounding
- ✅ Lesson generation pipeline: planner→smith→validate→fix→inject→build→test
- ✅ Web documentation fallback for latest Nim features
- ✅ Auto-qualify: single-quoted multi-char Nim validation codes auto-fixed
- ✅ Orphaned /tmp/nimlings_* cleanup on app startup and orchestrator test runs
## What's Setup

```
~/nimlings-fleet/
├── fleet-nimlings.sh     # Start/stop LLM server (Qwen2.5-Coder-14B)
├── orchestrator.py        # Main generation loop
├── nimdocs/               # Documentation retrieval module
│   ├── __init__.py        # Index builder & keyword retriever
│   └── src/               # Local Nim 2.2.10 docs (symlink)
├── nim-topics.json        # 238-topic comprehensive curriculum
├── proxy.py               # OpenAI-compatible API proxy
└── logs/                  # Session logs
```

## Usage

```bash
cd ~/nimlings-fleet

# 1. Start the fleet
./fleet-nimlings.sh start

# 2. Check coverage
python3 orchestrator.py --audit-only

# 3. Generate one lesson
python3 orchestrator.py --topic "2.5.6"

# 4. Continuous mode (fill all gaps)
python3 orchestrator.py --continuous

# 5. Rebuild doc index (after Nim update)
python3 orchestrator.py --rebuild-index
```

## Next Steps
- Manual review of complex topics: macros (3.2, 4.8), FFI (3.3), async (3.1), effect system (3.13), memory management (3.15), capstones (4.19, 4.20)
- Swap in Qwen3.6-27B when llama.cpp build supports it
- Consider adding solution test suite that validates each lesson's solution compiles and passes its validation_code
