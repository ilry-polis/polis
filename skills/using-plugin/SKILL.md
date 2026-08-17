---
name: using-plugin
description: Use to understand the whole Polis workflow, token-efficient context management, bounded subagent orchestration, TDD, review, and phase gates.
---

# Using Polis

Polis is one loop: **discuss → spec → plan → exec → verify**. For a new/large
project, roadmap sits between discuss and spec and cuts work into phases.

The goal is high-confidence engineering with minimal coordination waste: think
before building, plan coherent units, execute with TDD + atomic commits, and use
subagents only when their isolation or parallelism is worth another model thread.

## Phases

| Phase | Command | Skill | Produces |
|---|---|---|---|
| Discuss | `/polis:discuss` | brainstorming | approved design |
| Roadmap | `/polis:roadmap` | roadmapping | phased ROADMAP.md |
| Spec | `/polis:spec` | writing-specs | executable spec |
| Plan | `/polis:plan` | writing-plans | coherent tasks + batches |
| Exec | `/polis:exec` | executing-plans + subagent-dispatch + tdd | atomic commits |
| Verify | `/polis:verify` | finishing-work + code-review | merge-ready evidence |

Cross-cutting: context-mgmt, project-detect, code-review, debugging, and
verification-before-completion.

## Execution mental model

- Plans prefer roughly 5–12 meaningful tasks per feature phase, not 2–5 minute
  microtasks.
- Related tasks may form a batch of 1–3. One runner can execute the batch
  sequentially while keeping one TDD cycle + one commit per task.
- Trivial low-risk work may be executed directly when delegation would cost more
  than the work.
- Default write parallelism is at most 2 runners.
- Runner depth is exactly 1: no nested subagents.
- Waiting is bounded: one wave wait, useful coordinator work, at most one later
  wait. Never poll agents in a tight model loop.
- Low/medium-risk work gets one evidence-backed batch review; high-risk work gets
  stronger independent scrutiny.

## Context is a budget, not a delegation trigger

Keep the orchestrator lean with file anchors, targeted reads, concise outputs,
git, and STATE.md. A high context percentage means shrink/checkpoint/pause — it
does not mean "spawn another agent" automatically. Subagent workflows do their
own model/tool work, so delegation must have a reason.

## State

`.claude/polis/STATE.md` records phase, progress, decisions, commits, and the
pause/resume breadcrumb. Specs/plans hold intent; git holds implementation.
Store outcomes, not transcripts.

## Principles

1. Discuss/spec/plan before code.
2. Spend context on decisions/evidence, not replayed history.
3. Use the fewest coherent tasks and agent threads that preserve correctness.
4. TDD: RED → GREEN → REFACTOR.
5. One task, one reversible commit — even when tasks share a runner batch.
6. Review intensity follows risk.
7. State survives sessions.
8. The user controls phase transitions and irreversible actions.

When unsure, ask: *which phase am I in, what evidence is needed, and does another
agent actually buy enough isolation/speed to justify its coordination cost?*
