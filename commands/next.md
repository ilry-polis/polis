---
description: Detect the single best next action from the current state — phase, progress, context budget, and any pending pause. Routes you to the right command instead of making you decide. Read-only; it proposes, you decide.
argument-hint: ""
---

# /polis:next

Look at where things stand and propose the one most sensible next move. Useful
when you're returning to a project and aren't sure what's next, or just want the
system's recommendation.

## How it decides

Read the state and route by priority (first match wins):

1. **Pending pause** — STATE.md has a `Stopped At` breadcrumb → `/polis:resume-work`.
2. **Context HIGH/CRITICAL** — the monitor reads past 65% →
   finish + commit the current task, then `/polis:pause-work`.
3. **By phase:**
   - no design yet for the active feature → `/polis:discuss`
   - new project: design + ID'd requirements approved, no roadmap yet →
     `/polis:roadmap`
   - roadmap exists, current phase not specced → `/polis:spec <phase>`
   - design approved (single feature), no spec → `/polis:spec`
   - spec approved, no plan → `/polis:plan`
   - plan approved, tasks remaining → `/polis:exec` (name the next task)
   - all tasks done, phase not verified → `/polis:verify`
   - phase verified, more phases in roadmap → `/polis:spec` the next phase
   - verified, no more phases → propose the next milestone
4. **Uninitialized** — no `.claude/polis/` → `/polis:init`.

## Output

State the current situation in one line, then the recommended next action and
why, in one more. If a couple of moves are reasonable, name the top one and
mention the alternative. It proposes; the user decides — don't execute the next
action automatically.
