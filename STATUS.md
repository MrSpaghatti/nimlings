# nimlings Status

**Last updated:** 2026-06-14

## Project Overview

Interactive Nim tutor — 142 lessons across 4 levels. CLI application written in 100% Nim.

## Current Status: ✅ Stable — Expanded

- **Version:** 2.1.2
- **Branch:** `main` (ahead of origin)
- **Build:** Compiles cleanly (no warnings)
- **Tests:** All pass (Content, Engine, Models, Prerequisites, Solutions)
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

All 16 findings from AUDIT.md fixed (v2.1.2).

## What's Next

- Push to origin (already done)
