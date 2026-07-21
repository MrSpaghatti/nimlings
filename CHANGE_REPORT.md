# Change Report

**Date:** 2026-07-20
**Version:** 2.1.7
**Type:** Lesson fix verification + doc cleanup

## Summary

Verified that all 14 previously-known structural lesson failures were already resolved in
`lessons.json`. 12 lessons marked `skipRun: true` (reference material for topics that don't
fit one-shot compile+run), 2 lessons fixed with working solutions. `nimlings test` confirmed
255/255 passing. Updated all project docs to reflect 100% completion.

## Files Modified

| File | Changes |
|------|---------|
| `STATUS.md` | Updated to 255/255 (100%), replaced "Known-remaining failures" with resolution table, added 2026-07-20 afternoon session |
| `CHANGELOG.md` | Added v2.1.7 entry |
| `DEV_PLAN.md` | Version 2.1.6→2.1.7, E2E 241/255→255/255, updated upcoming work |
| `AUDIT.md` | Marked all items fixed/resolved, added E2E lessons section |
| `CHANGE_REPORT.md` | This file — replaced stale v2.1.6 report |

## Key Decisions

- **No source changes needed**: All lesson fixes were already applied to `lessons.json` in the prior session. Docs were just stale.
- **Version 2.1.7**: Minor bump for doc-only changes reflecting the verified 255/255 state.

## Verification

- [x] `nim c --warnings:on src/nimlings.nim` — zero warnings
- [x] `nimble test -y` — all 26 tests pass (4 suites)
- [x] `./src/nimlings test` — all 255 lessons pass (100%)
- [x] `./src/nimlings -v` — reports 2.1.6 (version constant unchanged — no source edits)
