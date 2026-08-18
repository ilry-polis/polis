---
name: subagent-dispatch
description: Use when delegation materially helps execution. Packages bounded batches with minimal context, prevents nested delegation and polling churn, limits parallel write work, and integrates only concise outcomes.
---

# Subagent Dispatch

Subagents trade tokens for isolation and parallelism. Use that trade only when it
pays. A fresh context is valuable for bounded implementation, exploration, or
high-risk isolation; it is wasteful when every tiny plan item becomes a new
thread.

## When to dispatch

Dispatch when at least one is true:

- the work is large/noisy enough to pollute the orchestrator;
- 1–3 related tasks benefit from one fresh implementation context;
- independent work has a real parallel speed benefit;
- high-risk work benefits from isolation or independent scrutiny.

Prefer direct execution for a trivial low-risk task when the main context is
healthy and delegation would add more handoff/review/wait turns than work.

## What to send

A runner has no useful chat history. Brief it with **anchors and constraints**:

- batch ID and 1–3 task IDs from the approved plan;
- exact plan/spec file paths and relevant section names/anchors;
- exact files or subsystem boundaries expected to change;
- non-obvious conventions/constraints only;
- required evidence and commit format.

Tell the runner to read named repository files as needed instead of pasting large
file contents into its prompt.

## What to withhold

- full chat transcript;
- whole spec/plan when only sections are relevant;
- unrelated tasks;
- raw output from earlier agents;
- reasoning narratives and historical debugging logs;
- broad codebase dumps the runner can retrieve itself.

## Runner contract

- Execute only the assigned batch, sequentially.
- Preserve one TDD cycle + one atomic commit per task.
- **Never spawn or delegate to another subagent.** Depth stays 1.
- Do not poll other agents or use agent-management tools.
- Report: task IDs, done/blocked, commit hashes, tests/checks, one-to-two-line
  summary, and only decisions/blockers the orchestrator must know.

## Waiting policy

Dispatch at most two write-capable runners concurrently by default. Then:

1. wait once for the active set;
2. if some are still active, perform useful coordinator work;
3. wait at most once more later;
4. do not loop on `wait`, `wait_agent`, `list_agents`, or equivalent status
   checks.

A status check is not progress. If results are not ready after the bounded wait
policy, surface that state instead of turning polling into hundreds of model
turns.

## Reviewing the return

Low/medium-risk batches get one combined compliance + quality review backed by
targeted tests/checks. High-risk work keeps stronger independent scrutiny.
Prefer a focused follow-up to the same runner for one repair round; do not spawn
a fresh fixer for every finding.

## Integrating without pollution

Pull back the outcome, not the transcript. The code and evidence live in git and
command output; STATE.md stores only durable facts. If the orchestrator starts
copying agent transcripts or repeatedly asking for status, stop and shrink the
coordination loop.
