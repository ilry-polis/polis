---
description: Break an approved spec into coherent atomic tasks, with exact file paths, test-first verification, dependencies, risk, execution batches, and an unambiguous done criterion. Avoid orchestration-heavy microtasks.
argument-hint: "[feature name]"
---

# /polis:plan

Produce the execution plan for an approved spec. Runs the writing-plans skill
(skills/writing-plans).

## What it does

1. Load the latest approved `.claude/polis/specs/spec-<feature>-v<n>.md`. If
   there's no approved spec, point to `/polis:spec`.
2. Run the quality loop — research → plan → verify → adjust:
   - Read the actual codebase before planning.
   - Break the spec into the **smallest set of coherent tasks**, not 2–5 minute
     microtasks. Default target: roughly 5–12 meaningful tasks per feature phase.
   - Each task has ID, behavior, exact file paths, expected code/pseudocode,
     test-first proof, dependencies, risk (`low|medium|high`), execution batch,
     and done criterion.
   - Group 1–3 related tasks into a batch when one bounded fresh-context runner
     can execute them sequentially. Each task still gets its own TDD cycle and
     atomic commit.
   - Verify every acceptance criterion maps to a task; nothing contradicts the
     spec; nothing extra sneaks in. Flag divergence to the user.
3. High-risk tasks normally get their own batch. Independent write-heavy work is
   not parallelized merely because it can be.
4. If the plan wants materially more than ~12 tasks, merge artificial microtasks
   first; if the scope is genuinely large, split the phase/plan instead.
5. Save as `.claude/polis/plans/plan-<feature>-v<n>.md` and advance STATE.md's
   phase to `plan` → ready for `exec`.

## Reminders

- Task count has an orchestration cost. More tasks are not automatically safer.
- The test in each task is the operational definition of done.
- Batch related work to reuse useful local context; do not batch unrelated work.
- Precise, not padded.
