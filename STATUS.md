# nimlings Status

**Last updated:** 2026-06-14 (polish round)

## Project Overview

Interactive Nim tutor — 142 lessons across 4 levels. CLI application written in 100% Nim.

## Current Status: ✅ Stable — Expanded

- **Version:** 2.1.3
- **Branch:** `main`
- **Build:** Compiles cleanly (zero warnings with `--warning:all`)
- **Tests:** All pass (Content, Engine, Models, Prerequisites, Solutions) — 13 streak tests added
- **CI:** GitHub Actions workflow at `.github/workflows/ci.yml`
- **Lessons:** 142/142 — all pass internal solution tests

## What's Here

- ✅ 142 lessons (was 120) — 22 new across L2-L4
- ✅ **New topics:** Regex, Data Structures (sets/tables/deques), OS & Filesystem, DateTime, Encoding, Text Parsing, Streams, Networking, Publishing & Documentation
- ✅ All prerequisite chain tests pass
- ✅ All 142 solutions compile and validate correctly
- ✅ Prerequisite tree with level gating (boss lessons)
- ✅ CLI: learn, watch, list, path, test, hint, solution, export/import
- ✅ TUI dashboard with ANSI progress bars
- ✅ Sandboxed execution with 5s timeout
- ✅ Daily streak tracking
- ✅ JS compilation backend support (with Node.js presence check)
- ✅ Project mode (nimble test runner)
- ✅ Automated lesson content generation from JSON

## Audit Resolved

All 16 findings from AUDIT.md fixed (v2.1.2). Streak date logic now has 13 test cases covering all edge cases.

## What's Next

- Push to origin
- CI will auto-verify on push
