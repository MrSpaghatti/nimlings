# Archived documents

These are **historical records**, kept for provenance. They are not maintained and
their numbers are frozen at the date they were written.

| File | What it was | Superseded by |
|---|---|---|
| `PLAN.md` | The 255 → 315 lesson expansion plan (Level 5 "Mastery"). Never executed — content was frozen at 255 instead. | `STATUS.md` |
| `DEV_PLAN.md` | A 2026-07-19 snapshot of state and key files. | `STATUS.md` |
| `AUDIT.md` | The 2026-07-24 deep-dive audit: findings E1–E4, I1–I7, S1–S4. | `STATUS.md` (open items) + `CHANGELOG.md` (fixes) |
| `CHANGE_REPORT.md` | The v2.1.9 change report for that audit cycle. | `CHANGELOG.md` |

**Read them for history, not for current state.** Two entries in `AUDIT.md` are
actively misleading if taken at face value:

- **I4** claims the generator's `files` table keys were fixed by changing `($ %k)` to
  `$k`, and that the path was "unreachable (all 255 lessons have empty `files` dicts)".
  Both halves were wrong: 13 lessons have non-empty `files` tables, and `$k` on a plain
  string emits the key **unquoted**, so `src/content.nim` did not compile at all
  (`undeclared identifier: 'helpers'`). Fixed 2026-11-05 by using `escape(k)`.
- **I1** (the `runWithTimeout` pipe deadlock) was left open as "latent". It is now fixed
  and covered by a regression test that writes >64 KiB.

Current state lives in [`../../STATUS.md`](../../STATUS.md); history in
[`../../CHANGELOG.md`](../../CHANGELOG.md).
