---
name: writing-plans
description: Use after a spec is approved and before execution. Produces a coarse execution plan made of a few coherent capability slices, with exact scope, verification strategy, dependencies, risk, and done criteria. Explicitly avoids file-by-file or microstep task explosion. Activates on /polis:plan.
---

# Writing Plans

A plan is a map of meaningful implementation slices, not a transcript of every
edit the agent expects to make. The spec already contains detail; the plan should
turn that detail into the **smallest useful set of execution units**.

## Default granularity

Prefer **3–7 tasks per feature phase**. A task should usually represent a coherent
capability, vertical slice, or technical boundary that can be implemented and
verified as one unit.

Do not create separate tasks for things that naturally belong together, such as:

- add type + repository method + service wiring for the same behavior;
- create migration + update generated/domain types for the same schema change;
- add endpoint + validation + handler + its focused tests;
- add component + state + API integration for one screen behavior;
- write test / write implementation / refactor as separate plan tasks.

Those are **steps inside one task**, not tasks themselves.

If a plan wants more than ~7 tasks, first merge artificial boundaries. If the
work is genuinely broader, split the feature into another phase/milestone rather
than producing 20–30 tiny tasks.

## The task

Every task carries only what execution needs:

1. **ID + outcome** — what capability is true when this task is done.
2. **Scope** — primary files/modules expected to change. Exact paths when known,
   but do not enumerate every incidental import or generated file.
3. **Implementation constraints** — architecture/contracts that must be obeyed;
   enough to prevent invention, not line-by-line pseudo-code.
4. **Verification strategy** — the smallest evidence that proves the task:
   targeted behavior tests, an existing suite, type/lint/build checks, migration
   validation, or manual/runtime evidence as appropriate.
5. **Dependencies** — only real ordering constraints.
6. **Risk** — `low`, `medium`, or `high`. Auth, permissions, billing/payments,
   security, privacy, destructive data work, and migrations default high.
7. **Done criterion** — observable acceptance evidence tied back to the spec.

## Testing granularity

Plan **tests for behavior, not for edits**. Do not invent one new test for every
file touched, helper introduced, wiring change, or implementation step.

- New/changed behavior should have focused automated coverage where practical.
- Several assertions may belong to one behavior-level test when they prove one
  outcome.
- Docs, comments, formatting, generated artifacts, purely mechanical renames,
  and configuration-only changes do not require fabricated RED tests; verify
  them with the appropriate deterministic check instead.
- Prefer extending an existing test that already owns the behavior over creating
  a redundant new test file.

TDD still governs behavior-changing production code (see skills/tdd); the plan
simply stops turning the TDD cycle itself into multiple orchestration tasks.

## Execution batches

Because tasks are now coarse, batching should also be conservative:

- Default: **one task per runner** when the task is substantial.
- Up to **2 closely related low/medium-risk tasks** may share one runner when
  doing so clearly reuses local context and they do not create an integration
  seam.
- High-risk tasks stay isolated.
- Never batch unrelated work just to hit a number.

The goal is fewer agent starts without recreating a giant all-purpose task.

## Quality loop

Use **research → plan → verify → adjust**:

- inspect the actual codebase and existing tests;
- draft 3–7 coherent slices;
- map every acceptance criterion to at least one slice;
- merge file-by-file or step-by-step microtasks;
- split only when a task crosses unrelated responsibilities or cannot be safely
  verified/reverted as one unit.

If plan and spec diverge, flag it to the user. Do not silently let the plan win.

## Output

Save as `.claude/polis/plans/plan-<feature>-v<n>.md`. Keep it short enough that
execution can understand the phase without re-reading a verbose implementation
script. A good plan says **what coherent slice to deliver and how to prove it**;
the runner decides the ordinary intermediate edits.
