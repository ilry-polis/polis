---
description: Execute an approved plan with token-efficient batching, bounded subagents, TDD, atomic commits, risk-based review, and anti-polling guardrails.
argument-hint: "[feature name]"
---

# /polis:exec

Run the approved plan using `skills/executing-plans` and
`skills/subagent-dispatch`.

## What it does

1. Load the latest approved `.claude/polis/plans/plan-<feature>-v<n>.md`. If no
   approved plan exists, point to `/polis:plan`.
2. Read orchestration settings from `.claude/polis/config.json` when present.
   Defaults: `maxTasksPerBatch=3`, `maxConcurrentAgents=2`,
   `maxWaitCyclesPerWave=2`, `reviewMode=risk-based`.
3. Execute batches in dependency order:
   - For trivial low-risk work with healthy context, direct execution is allowed.
   - Otherwise dispatch one `polis-task-runner` for 1–3 related tasks.
   - Each task still runs RED → GREEN → REFACTOR and ends in one atomic commit.
   - Runners may not spawn nested subagents.
4. Parallelize only genuinely independent work, with at most two write-capable
   runners active by default.
5. After a wave, wait once for the active set. If needed, do useful coordinator
   work and wait once more later. Never tight-loop `wait`, `wait_agent`,
   `list_agents`, or status checks.
6. Review at the batch boundary:
   - low/medium risk: one combined compliance + quality pass with targeted tests,
     lint/type checks as relevant;
   - high risk: stronger independent scrutiny and relevant integration evidence.
   Full-suite verification belongs at meaningful integration boundaries and
   `/polis:verify`, not after every microtask.
7. Prefer one focused follow-up to the same runner for a defect. Two failed
   repair attempts ⇒ stop and surface the gap; do not keep spawning fix agents.
8. Record concise outcomes/commit hashes in STATE.md; never ingest full agent
   transcripts.

## Reminders

- Subagents are a deliberate trade: use them when isolation/parallelism is worth
  the additional model work.
- Fewer meaningful tasks and bounded batches beat dozens of microthreads.
- The orchestrator coordinates; it does not poll for entertainment.
- Don't improvise around the spec. If execution stops being mechanical, go back
  to debugging/spec rather than multiplying agents.
