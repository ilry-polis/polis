---
name: executing-plans
description: Execute an approved coarse-grained plan with token-efficient orchestration. Runs coherent capability tasks in bounded batches, uses subagents only where isolation helps, avoids polling loops, uses behavior-focused verification, preserves atomic commits, and escalates review by risk.
---

# Executing Plans

Execution should spend tokens on implementation and meaningful evidence, not on
coordination, redundant tests, or repeated reviews. The orchestrator owns
sequencing and durable state; runners handle coherent capability slices when a
fresh context materially helps.

## Execution policy

Read `.claude/polis/config.json` when present. Defaults:

- `maxTasksPerBatch`: **2**
- `maxConcurrentAgents`: **2**
- `maxWaitCyclesPerWave`: **2**
- `reviewMode`: **risk-based**

These are ceilings, not targets. With a coarse 3–7 task plan, one task may already
be a substantial vertical slice; batching is optional and should only combine
closely related low/medium-risk tasks.

## The loop, per task/batch

1. **Choose direct vs runner.**
   - Direct execution is allowed for trivial low-risk work when delegation costs
     more than the implementation and the orchestrator is healthy.
   - Otherwise dispatch one `polis-task-runner` for one coherent task, or at most
     two closely related tasks when reuse of local context is clearly valuable.
   - High-risk work normally gets an isolated runner.

2. **Brief by anchors, not transcript.** Send task IDs, relevant plan/spec
   anchors, primary files/modules, constraints, and done evidence. Never send
   chat history, unrelated tasks, whole specs, or large pasted source when the
   runner can read named repository files itself.

3. **Execute the coherent slice.**
   - Observable behavior change: use RED → GREEN → REFACTOR at the behavior
     boundary. Reuse/extend owning tests where possible.
   - Mechanical/non-behavioral work: do not manufacture a RED test. Use the
     strongest cheap deterministic evidence (existing test, typecheck, lint,
     build, schema/migration/config validation, focused integration check).
   - Do not split one capability into repeated test/implementation/review cycles
     just because multiple files are involved.
   - One atomic commit per plan task.

4. **Wait without polling.** After dispatching a wave, wait once for the active
   set. If some remain active, do useful coordinator work before at most one
   later wait. Never loop `wait`, `wait_agent`, `list_agents`, or status checks
   merely to ask whether work is done. After the second wait cycle, stop polling
   and surface status.

5. **Review once at the useful boundary.**
   - Low/medium risk: one concise compliance + quality pass per completed task or
     batch, not separate reviewers and not a second review ceremony for every
     file/edit.
   - High risk (auth, authorization, billing/payments, security, destructive
     data/migrations, privacy boundaries): stronger independent scrutiny.
   - If targeted evidence is clean and diff is straightforward, review should be
     short. Do not invent findings or extra test work to justify the review.

6. **Repair in place.** Prefer a focused follow-up to the same runner while its
   context remains useful. Do not spawn a new fix agent for every finding. Stop
   after two failed repair attempts on the same defect.

7. **Record, don't accumulate.** STATE.md gets task IDs, commit hashes, decisions,
   blockers, and a one-to-two-line outcome. Never import full transcripts,
   diffs, test logs, or agent chatter into the orchestrator.

## Parallel waves

Parallelism is optional, not a goal. For write-heavy work:

- maximum **2 active runners** by Polis policy;
- never parallelize tasks touching the same files/integration seam;
- prefer sequential execution when one capability feeds the next;
- parallelize only when the expected wall-clock gain is worth another model
  context and coordination path.

## Verification boundaries

- During implementation: targeted evidence only.
- At a meaningful integration boundary: one broader check if warranted.
- At `/polis:verify`: holistic suite/lint/type/build/spec verification.

The same full suite should not be rerun after every task unless a high-risk
boundary genuinely requires that breadth.

## Context discipline

Keep the main session lean, but do not create subagents merely to satisfy an
arbitrary context percentage. First reduce reads/output using anchors, summaries,
git commits, targeted commands, and pause/resume. Delegation is a tool, not the
default unit of work.

At WARNING: avoid broad output and finish the current task/batch. At
HIGH/CRITICAL: checkpoint and pause/resume before starting another.

## Stop conditions

Halt and consult the user if the plan/spec is contradictory, a defect survives
two focused repairs, a design assumption fails, or progress would require
breaking agent/wait guardrails. Return to debugging/specification rather than
multiplying agents or ceremonies.
