---
name: executing-plans
description: Use to execute an approved plan with token-efficient orchestration. Runs related tasks in bounded batches, uses subagents only where isolation helps, caps parallel write work, avoids polling loops, preserves TDD and atomic commits, and escalates review by risk.
---

# Executing Plans

Execution should spend tokens on implementation and verification, not on
coordination churn. The orchestrator owns sequencing and durable state; runners
handle bounded batches when fresh context materially helps.

## Execution policy

Read `.claude/polis/config.json` when present. Defaults:

- `maxTasksPerBatch`: **3**
- `maxConcurrentAgents`: **2**
- `maxWaitCyclesPerWave`: **2**
- `reviewMode`: **risk-based**

These are ceilings, not targets. One runner is preferable when parallelism adds
coordination without meaningful wall-clock benefit.

## The loop, per batch

For each approved execution batch in dependency order:

1. **Choose direct vs runner.**
   - Direct execution is allowed for a trivial, low-risk task when delegating it
     would cost more coordination than doing it and the orchestrator is healthy.
   - Otherwise dispatch **one `polis-task-runner` for 1–3 related tasks**. Do not
     spawn one runner per microstep.
   - High-risk work normally gets an isolated runner and its own batch.

2. **Brief by anchors, not transcript.** Send task IDs, the relevant plan/spec
   sections, exact file paths, constraints, and done evidence. Never send chat
   history, unrelated tasks, whole specs, or large pasted source when the runner
   can read the named files itself.

3. **Runner executes sequentially.** For every task in its batch: RED → GREEN →
   REFACTOR, then one atomic commit `[polis] T<n>: <what>`. The runner must not
   spawn subagents of its own.

4. **Wait without polling.** After dispatching a wave, make one wait for the
   active set. If some remain active, do useful coordinator work (state,
   integration prep, independent deterministic checks) before at most one later
   wait. **Never loop `wait`, `wait_agent`, `list_agents`, or status checks just
   to ask whether work is done.** If the wave still has no actionable result
   after the second wait cycle, stop the orchestration loop and surface status
   instead of burning model turns.

5. **Review by risk, once at the right boundary.**
   - Low/medium risk: inspect the batch diff/outcome, run targeted tests and
     lint/type checks once for the batch, and review compliance + quality in one
     pass.
   - High risk (auth, permissions, billing, security, destructive data/migration
     boundaries): keep independent compliance + quality scrutiny and the
     strongest relevant verification.
   - Do not rerun a full suite after every small task. Run targeted evidence per
     task/batch; reserve the full suite for integration boundaries and `/polis:verify`.

6. **Repair in place.** Prefer one focused follow-up to the same runner while its
   context is useful. Do not spawn a fresh fix agent for every finding. After two
   failed repair attempts on the same defect, stop and escalate the gap.

7. **Record, don't accumulate.** STATE.md gets task IDs, commit hashes, decisions,
   blockers, and a one-to-two-line batch outcome. Do not import full transcripts,
   diffs, test logs, or agent chatter into the orchestrator.

## Parallel waves

Parallelism is for genuinely independent work, especially read-heavy work. For
write-heavy execution:

- maximum **2 active runners** by default;
- never parallelize batches that touch the same files or integration seam;
- prefer sequential execution when one batch feeds the next;
- start another runner only when the expected speedup is worth another model
  context and coordination path.

## Context discipline

Keep the main session lean, but **do not create subagents merely to satisfy an
arbitrary context percentage**. First reduce what the orchestrator reads: use
file anchors, summaries, git commits, targeted command output, and pause/resume.
Delegation is a tool, not the default unit of work.

At WARNING: avoid loading broad output and finish the current batch. At
HIGH/CRITICAL: checkpoint and pause/resume before starting another batch.

## Stop conditions

Halt and consult the user if:
- the plan/spec is wrong or contradictory;
- the same defect survives two focused repair attempts;
- a design assumption no longer holds;
- the workflow would exceed its agent/wait guardrails to make progress.

When execution stops being mechanical, return to debugging/specification rather
than multiplying agents.
