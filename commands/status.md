---
description: Show current Polis project state at a glance — workflow phase, task progress, last commit, git snapshot, and the best next action. On Codex, context usage comes from the native /status or /statusline UI, not a Polis monitor.
argument-hint: ""
---

# /polis:status

A quick read of where the project stands. Read-only; changes nothing.

## Steps

1. **Project state.** If `.claude/polis/STATE.md` exists, summarize milestone, phase, progress, last commit, and whether a `Stopped At` breadcrumb exists. If missing, report that Polis is not initialized and suggest `/polis:init`.

2. **Git snapshot.** Report current branch, short HEAD hash, uncommitted-file count, and whether merge/rebase is in progress.

3. **Context status — runtime native.**
   - **Codex:** do not read `polis-ctx-*` files and do not calculate a Polis percentage. Tell the user to rely on the native footer configured via `/statusline` (`context-remaining`, `context-used`, `context-window-size`) or `/status` when they want a detailed snapshot. If the current runtime/tool surface already exposes those native values, report them directly.
   - **Claude/Cursor:** report native context information if the runtime exposes it. Do not fabricate an estimate when it does not.

4. **Next action.** End with the single most sensible workflow step from durable project state (resume pending, continue exec at task N, verify, spec next phase, etc.). Do not base the recommendation on Polis-specific context thresholds.

## Output shape

Keep it tight: phase, progress, branch, native context signal if available, next action. No walls of text.
