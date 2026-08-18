---
description: Turn an approved spec into a coarse execution plan of roughly 3-7 coherent capability slices. Each task defines outcome, bounded scope, verification strategy, dependencies, risk, and done criteria. Avoid file-by-file and test-by-test microtasks.
argument-hint: "[feature name]"
---

# /polis:plan

Produce the execution plan for an approved spec. Runs the writing-plans skill
(`skills/writing-plans`).

## What it does

1. Load the latest approved `.claude/polis/specs/spec-<feature>-v<n>.md`. If no
   approved spec exists, point to `/polis:spec`.
2. Inspect the real codebase and existing tests before planning.
3. Break the spec into the **smallest useful set of coherent implementation
   slices**. Default target: **3–7 tasks per feature phase**.
4. A task represents a capability/vertical slice/technical boundary — not an
   individual file edit, test, type, helper, migration statement, or TDD step.
5. Each task records:
   - outcome/capability;
   - primary scope/files/modules;
   - architectural constraints;
   - verification strategy;
   - real dependencies;
   - risk (`low|medium|high`);
   - observable done criterion tied to the spec.
6. Verify every acceptance criterion maps to at least one task and nothing extra
   enters the plan.
7. If the plan exceeds ~7 tasks, merge artificial microtasks first. If the scope
   is genuinely too broad, split the feature into another phase instead.
8. Save as `.claude/polis/plans/plan-<feature>-v<n>.md` and advance STATE.md to
   `plan` → ready for `exec`.

## Granularity rules

These normally belong in **one task**, not separate tasks:

- schema/migration + matching domain/generated types;
- endpoint + validation + service/handler + focused behavior tests;
- component + state + API integration for one user-visible behavior;
- failing test + implementation + refactor (the TDD cycle is internal to the task);
- related mechanical wiring required to make one behavior work end-to-end.

Split only when work crosses unrelated responsibilities, has a real dependency
boundary, needs independent rollback, or has materially different risk.

## Testing rule

Plan verification **per behavior/capability**, not per edit. Do not manufacture a
new test merely because another file changed. Reuse/extend the test that owns the
behavior when possible; use type/lint/build/migration/config validation for
mechanical changes that do not introduce behavior.

## Reminders

- More tasks are not automatically safer; every task creates orchestration,
  execution, test, commit, and review overhead.
- Precise scope beats step-by-step implementation narration.
- A good plan says what slice must exist and how to prove it — not every command
  the runner should execute.
