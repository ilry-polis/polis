---
name: executing-plans
description: Use to execute an approved plan, task by task, via isolated subagents with fresh context. Activates on /polis:exec. Keeps the orchestrator under 40% by delegating heavy work; enforces TDD per task, atomic commits, and a two-phase (compliance + quality) review after each task. Auto-pauses when context hits WARNING.
---

# Executing Plans

Execution is where the architecture earns its keep. The orchestrator does not
write the code — it dispatches each task to a subagent with a fresh window,
reviews what comes back, and keeps a clean state. Heavy lifting happens where
there's room for it; the orchestrator stays a lean coordinator.

## The loop, per task

For each task in the approved plan, in dependency order:

1. **Dispatch to a subagent.** Hand it the minimum it needs: the relevant spec
   section, the task definition (incl. its test), and just enough surrounding
   context to act. Not the whole project, not the chat history. (See
   skills/subagent-dispatch for how to package this.)

2. **Subagent does TDD.** RED → GREEN → REFACTOR, non-negotiable (see
   skills/tdd). It writes the failing test first, confirms it fails for the
   right reason, writes the minimal code to pass, refactors if needed, keeps the
   suite green.

3. **Two-phase review** of what the subagent returns:
   - **Phase 1 — Compliance:** does the code implement what the spec and task
     asked, no more and no less? Are the acceptance criteria met?
   - **Phase 2 — Quality:** does it follow the codebase's conventions? Any code
     smells, dead code, leftover debug output, fragile tests?
   If either phase fails, send it back to a subagent to fix *before* advancing.
   Don't accumulate debt across tasks.

4. **Atomic commit.** One task, one commit, with a standardized message that
   references the task ID — e.g. `[polis] T4: add session-expiry guard`.
   Reversible and traceable.

5. **Record, don't accumulate.** Capture the *outcome* in STATE.md (task done,
   commit hash, any decision made). Do not pull the subagent's full transcript
   back into the orchestrator — that's how the window fills.

## Context discipline during execution

- Target: orchestrator **under 40%** throughout. The whole reason work goes to
  subagents is to keep it there.
- If the monitor reports **WARNING (40%+)** mid-execution: finish the *current*
  task, commit it, and auto-pause (`/polis:pause-work`). Do not start the next
  task in a degraded orchestrator. Resume with fresh context.
- At **HIGH/CRITICAL**, the same reflex applies, more urgently — see
  skills/context-mgmt.

## Parallel waves

Tasks with no dependency between them can run as a wave of parallel subagents.
Only parallelize genuinely independent tasks — if two tasks touch the same file
or one's output feeds the other, they're sequential. After a wave returns,
review each result and resolve any integration seams before the next wave.

## Stop conditions

Halt and consult the user if:
- a task can't be done as specified (the spec/plan was wrong) — don't improvise
  around the spec, flag the mismatch;
- review keeps failing on the same task after a couple of fix attempts;
- the work reveals a design assumption that no longer holds.

When a task breaks in a way that isn't a quick correct fix — a test won't go
green, behavior surprises you — switch into systematic debugging
(skills/debugging) rather than guessing at patches. And never mark a task done on
a subagent's say-so: verify the green independently (skills/verification-before-completion).

Execution is mechanical *because* the thinking was front-loaded into discuss,
spec, and plan. When execution stops being mechanical, that's a signal an
earlier phase has a gap — go back, don't push through.
