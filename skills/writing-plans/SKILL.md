---
name: writing-plans
description: Use after a spec is approved and before execution. Breaks the spec into coherent, atomic implementation tasks with exact file paths, test-first verification, dependencies, risk, execution-batch hints, and an unambiguous done criterion. Avoids microtasks that create unnecessary orchestration overhead. Activates on /polis:plan.
---

# Writing Plans

A plan turns an approved spec into a sequence of meaningful, verifiable changes.
If the spec is the contract, the plan is the build sheet. The goal is not the
largest possible task count; it is the smallest set of coherent tasks that can
be implemented, tested, reviewed, and reverted safely.

## The atomic task

A task is **one coherent implementation unit**, not a 2–5 minute microstep. It
should complete one TDD cycle and end in one reversible commit without mixing
unrelated concerns.

Good task boundaries usually combine the test and implementation needed for one
behavior. Do **not** create separate tasks for "add test", "add type", "wire
handler", and "update call site" when those edits are one behavior and must land
together.

As a default, prefer roughly **5–12 meaningful tasks per feature phase**. If a
plan wants materially more than that, first try to merge artificial microtasks;
if the work is genuinely that large, split the feature into another phase or
plan. Task count is a coordination cost.

Every task carries:

1. **ID** — sequential and unique (T1, T2, ...). Referenced by dependencies and
   commits.
2. **Description** — precisely what behavior to implement. No hand-waving.
3. **File paths** — the exact files expected to change. Not "the auth module" —
   `src/auth/session.ts`.
4. **Expected code or pseudo-code** — enough to constrain the approach without
   narrating the whole implementation.
5. **Test first** — the test that proves the behavior, written before production
   code. This is the RED of the TDD cycle (see skills/tdd).
6. **Dependencies** — which tasks must complete first.
7. **Risk** — `low`, `medium`, or `high`. Auth, permissions, billing/payments,
   destructive data changes, security boundaries, and migrations default high.
8. **Execution batch** — a suggested batch ID (B1, B2, ...). Put 1–3 related
   tasks in one batch when they share a bounded area and can be executed by one
   fresh-context runner without ambiguity. Keep conflicting or unrelated tasks
   separate.
9. **Done criterion** — unambiguous evidence: targeted test green plus any spec
   acceptance criterion satisfied by the task.

## Batch design

Execution batches are a cost-control boundary, not a reason to weaken atomicity:

- A batch may contain **1–3 related tasks**.
- Each task still gets its own TDD cycle and atomic commit.
- Prefer sequential tasks in the same subsystem when one runner can retain useful
  local context across them.
- Parallel batches must be genuinely independent. Avoid parallel write-heavy
  batches that touch the same files or integration seam.
- A high-risk task should normally be its own batch.

This lets execution reuse one fresh context for a few related commits instead of
paying the spawn / handoff / wait / review overhead for every microstep.

## The quality loop

Don't write a plan once and ship it. Loop:

**research → plan → verify → adjust**, until the plan passes its own review:

- **research:** inspect the actual codebase. What exists? What conventions?
  What will each task really touch? A plan written without reading the code is
  fiction.
- **plan:** draft the smallest coherent task set and batches.
- **verify:** check the plan against the spec. Every acceptance criterion maps to
  at least one task; no task contradicts the spec; nothing extra sneaks in.
- **adjust:** merge artificial microtasks, split genuine oversized work, fix
  dependency/risk labels, and re-verify.

If the plan and spec diverge, **flag it to the user** — don't silently let the
plan win.

## Context-sized

Each batch must fit comfortably in a fresh subagent's context window *with room
to work*. If a feature is too large, split it into multiple plans per milestone.
The runner should receive task IDs, exact plan/spec anchors, and minimal
surrounding context — never the chat transcript or whole project.

## Versioning & output

Save as `.claude/polis/plans/plan-<feature>-v<n>.md`. New version on material
change; the latest approved version is what `/polis:exec` runs.

## Precise, not padded

A task list earns nothing from verbosity or task count. State each task in the
fewest words that leave no ambiguity. A short, exact plan reduces both context
load and orchestration turns during execution.
