# Fix Plan

**Date:** 2026-06-26
**Source:** Audit Report (v2.1.3)

---

### Batch 1: Trivial Cleanup (high impact on code clarity, smallest effort)

| # | Effort | File | Fix |
|---|--------|------|-----|
| I1 | ~30s | `engine.nim` | Remove unused `import tables` |
| I2 | ~1m | `tests/test_models.nim` | Remove dead "State JSON round-trip" test |
| I3 | ~30s | `tui.nim` | Replace useless 3-branch conditional with `let fire = "🔥"` |

### Batch 2: Test Coverage (medium impact, small effort)

| # | Effort | File | Fix |
|---|--------|------|-----|
| S1 | ~2m | `tests/test_content.nim` | Add non-empty checks for `conceptText`, `task`, `solution`, `hint`, `difficulty` |

### Batch 3: Nice-to-have (low impact)

| # | Effort | File | Fix |
|---|--------|------|-----|
| S2 | ~10m | `models.nim` | Replace manual date arithmetic with `times.parse()` + `inDays` — works correctly today, just verbose |

---

**Total:** 4 trivial changes + 1 optional cleanup. ~5 minutes for Batches 1-2.

## Verification Plan

1. `nim check` after each batch
2. Full `nimble test` after all batches
3. `nim c --warnings:on src/nimlings.nim` for zero warnings
