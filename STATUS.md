# nimlings Status

**Last updated:** 2026-06-14

## Project Overview

Interactive Nim tutor — 120 lessons across 4 levels. CLI application written in 100% Nim.

## Current Status: ✅ Stable — Audit Cleared

- **Version:** 2.1.2
- **Branch:** `main` (ahead of origin)
- **Build:** Compiles cleanly (no warnings)
- **Tests:** All pass (Content, Engine, Models, Prerequisites)
- **Lessons:** 120/120 complete with difficulty ratings and cross-language notes

## What's Here

- ✅ 120 lessons covering Nim from "Hello World" to macros/DSL
- ✅ Prerequisite tree with level gating (boss lessons)
- ✅ CLI: learn, watch, list, path, test, hint, solution, export/import
- ✅ TUI dashboard with ANSI progress bars
- ✅ Sandboxed execution with 5s timeout
- ✅ Daily streak tracking
- ✅ JS compilation backend support (with Node.js presence check)
- ✅ Project mode (nimble test runner)
- ✅ Automated lesson content generation from JSON

## Audit Resolved

All findings from AUDIT.md have been fixed:
- **Errors:** Version sync, silent data loss, inconsistent findLesson, fragile splitLines — all resolved
- **Hallucinations:** Stack trace disabling (--d:release removed), Node.js check added, dead stderr field documented
- **Inefficiencies:** canSkip overload, polling interval tuned
- **Style:** Dead types/procs removed, imports cleaned, printHelp simplified, generator cleanup

## What's Next

- Push to origin
- Tag v2.1.2 release
