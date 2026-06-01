---
description: Save a complete session snapshot to STATE.md, commit pending work atomically, and prepare for /compact or a fresh session. Use at HIGH/CRITICAL context, or any time you need to stop without losing your place.
argument-hint: "[optional one-line summary of where you are]"
---

# /polis:pause-work

Capture everything needed to resume later with zero loss, then make the working
tree durable. Run this before `/compact` or before ending a session mid-task.

## Steps

1. **Gather state.** Determine, from the current session:
   - Current workflow phase: one of discuss / spec / plan / exec / verify.
   - The task in progress: its ID, description, and how far it got.
   - The next planned task.
   - Files modified since the last commit: run `git diff --name-only` and
     `git status --short`.
   - A short prose summary of what you were doing and any decisions just made.
   - The hash of the last commit: `git rev-parse --short HEAD`.

2. **Write `.claude/polis/STATE.md`.** Overwrite the live fields and fill the
   `Stopped At` breadcrumb with enough detail that a fresh session — or a
   different agent — could resume without asking you anything. Use this shape:

   ```
   # Polis — Project State
   ## Current Milestone: <name>
   ## Phase: <discuss|spec|plan|exec|verify>
   ## Progress: <x/y tasks complete>
   ## Last Commit: <hash + message>
   ## Previous Session: <timestamp + one-line summary>
   ## Decisions: <bulleted list>
   ## Notes: <important context>
   ## Stopped At: <detailed breadcrumb — current task, exact next action,
   ##            open questions, anything half-done>
   ```

   If `$ARGUMENTS` is provided, use it as the headline of the `Stopped At`
   breadcrumb.

   Note: the context monitor may have already appended an auto-breadcrumb block
   (marked `POLIS:CRASH-BREADCRUMB`). Fold its facts into `Stopped At` and you
   may remove the auto block once incorporated.

3. **Commit atomically.** Stage the pending work and commit with a standardized
   message so pauses are greppable in history:

   ```
   [polis] pause: <summary>
   ```

   If there is genuinely nothing to commit, say so and skip — do not create an
   empty commit.

4. **Hand off.** Tell the user, in one or two lines: what was saved, the commit
   hash, and the exact next step (`/compact` then `/polis:resume-work`, or start
   a fresh session and `/polis:resume-work`).

## Guardrails

- Never force-push, never rebase, never amend someone else's commit here.
- If `git status` shows a merge in progress or conflicts, do not commit — report
  the conflict and let the user resolve it first.
- Pausing is a clean stop, not a destructive one. No file deletions.
