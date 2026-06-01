---
description: Show the current Polis state at a glance — workflow phase, task progress, last commit, and the estimated context budget.
argument-hint: ""
---

# /polis:status

A quick read of where the project and the session stand. Read-only; changes
nothing.

## Steps

1. **Project state.** If `.claude/polis/STATE.md` exists, summarize its live
   fields: milestone, phase, progress (x/y tasks), last commit, and whether a
   `Stopped At` breadcrumb is present (meaning a pause is pending a resume).
   If it doesn't exist, report that Polis isn't initialized here and suggest
   `/polis:init`.

2. **Git snapshot.** Report the current branch, the short HEAD hash, and a count
   of uncommitted files (`git status --short | wc -l`). Note if a merge/rebase
   is in progress.

3. **Context budget.** Read the most recent `polis-ctx-*.json` bridge file from
   the OS temp dir and report the estimated percentage and threshold. Remind the
   user, in a few words, that this is a conservative estimate, not a measured
   value. If no bridge exists yet, say the monitor hasn't recorded anything this
   session.

4. **Next action.** End with the single most sensible next step given the state
   (e.g. "resume-work pending", "continue exec at task 4", "context HIGH —
   finish and commit current task").

## Output shape

Keep it tight — a short block, not a report. Phase, progress, branch, context,
next action. No walls of text.
