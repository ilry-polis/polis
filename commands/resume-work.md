---
description: Restore context from STATE.md and resume exactly where you left off. Detects incomplete work, git conflicts, and manual changes since the pause, then routes to the right workflow phase.
argument-hint: ""
---

# /polis:resume-work

Reconstruct the working context from the last pause and continue without loss.

## Steps

1. **Load state.** Read `.claude/polis/STATE.md`. If it doesn't exist, say so
   and offer to run `/polis:init` or `/polis:status` instead — there is nothing
   to resume.

2. **Reconstruct context.** Restate to the user, briefly:
   - The milestone and phase you were in.
   - The task that was in progress and the recorded next action.
   - The decisions and notes that matter for continuing.
   Pull these from the `Stopped At` breadcrumb first; it's the freshest.

3. **Detect drift.** Before resuming, check what changed since the pause:
   - **Incomplete work:** does `git status --short` show uncommitted changes
     that the breadcrumb implies should exist (or shouldn't)?
   - **New commits:** is `git rev-parse --short HEAD` different from the
     `Last Commit` in STATE.md? If so, work happened outside this thread —
     summarize the new commits with `git log --oneline <state-hash>..HEAD`.
   - **Conflicts:** is a merge or rebase in progress? If so, surface it and stop
     until resolved.
   - **Manual edits:** if files changed in ways the breadcrumb didn't predict,
     flag them and ask whether to incorporate or set aside.

4. **Route intelligently.** Based on the recorded phase and the drift check,
   pick the resume path and confirm it with the user before acting:
   - Mid **exec** → return to execution at the correct task. If the prior task
     was half-done, decide with the user: finish it, or reset and redo cleanly.
   - Mid **verify** → return to verification against the spec.
   - **Plan changed** (the breadcrumb or new commits invalidate the plan) →
     re-validate the plan against the spec before continuing; if it diverged,
     flag it and propose an updated plan.
   - **Everything complete** → don't invent work. Summarize what's done and
     propose the next milestone.

5. **Resume.** Once the path is confirmed, continue the workflow. Update
   STATE.md's `Phase`/`Progress`/`Previous Session` fields to reflect that the
   session is live again, and clear the stale `Stopped At` once you've safely
   picked the work back up.

## Guardrails

- Confirm the route before taking irreversible action — resume proposes, the
  user decides.
- Never discard uncommitted work without explicit confirmation.
- If STATE.md and the git history disagree, trust git for *what exists* and
  STATE.md for *intent*, and reconcile out loud.
