---
description: Execute an approved plan task by task via isolated subagents with fresh context. Enforces TDD, atomic commits, and two-phase (compliance + quality) review per task. Keeps the orchestrator under 40% and auto-pauses at WARNING.
argument-hint: "[feature name]"
---

# /polis:exec

Run the approved plan. Runs the executing-plans skill (skills/executing-plans)
and dispatches via skills/subagent-dispatch.

## What it does

1. Load the latest approved `.claude/polis/plans/plan-<feature>-v<n>.md`. If
   there's no approved plan, point to `/polis:plan`.
2. For each task in dependency order:
   - Dispatch to a subagent with a fresh window: the task, the relevant spec
     section, and minimal context — not the chat history or whole codebase.
   - Subagent executes TDD (RED → GREEN → REFACTOR) and makes the atomic commit
     (`[polis] T<n>: <what>`).
   - Run the two-phase review (compliance, then quality). On failure, dispatch a
     focused fix before advancing.
   - Record the outcome (not the transcript) in STATE.md; update progress.
3. Run independent tasks as parallel waves where it's safe; resolve integration
   seams between waves.
4. Keep the orchestrator under 40%. At WARNING, finish and commit the current
   task, then auto-pause (`/polis:pause-work`) and resume with fresh context.

## Reminders

- The orchestrator coordinates; subagents do the heavy work. Don't read large
  subagent outputs back into the main window.
- Don't improvise around the spec. If a task can't be done as specified, the
  spec/plan has a gap — flag it, don't push through.
- When execution stops being mechanical, an earlier phase has a hole. Go back.
