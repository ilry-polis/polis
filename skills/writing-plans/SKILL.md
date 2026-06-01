---
name: writing-plans
description: Use after a spec is approved and before execution. Breaks the spec into atomic 2-5 minute tasks, each with an exact file path, expected code, a test written before the code, dependencies, and an unambiguous done criterion. Activates on /polis:plan. The plan must fit in a fresh subagent's context window.
---

# Writing Plans

A plan turns an approved spec into a sequence of small, verifiable moves. If the
spec is the contract, the plan is the build sheet — granular enough that
executing it is almost boring.

## The atomic task

Each task is **2–5 minutes of work**: one coherent change a subagent can do,
test, and commit before moving on. If a task feels bigger than five minutes,
split it. Small tasks are easier to verify, easier to revert, and survive a
context reset without leaving half-built rubble.

Every task carries:

1. **ID** — sequential and unique (T1, T2, ...). Referenced by dependencies and
   commits.
2. **Description** — precisely what to implement. No hand-waving.
3. **File paths** — the exact files to create or modify. Not "the auth module" —
   `src/auth/session.ts`.
4. **Expected code or pseudo-code** — enough that the subagent isn't inventing
   the approach, just realizing it.
5. **Test first** — the test that validates the task, written *before* the
   implementation. This is the RED of the TDD cycle (see skills/tdd). The test
   defines "done" operationally.
6. **Dependencies** — which tasks must complete first. This is what lets
   independent tasks run in parallel waves later.
7. **Done criterion** — unambiguous. Usually "test T-n passes and the suite is
   green," plus any spec acceptance criterion it satisfies.

## The quality loop

Don't write a plan once and ship it. Loop:

**research → plan → verify → adjust**, until the plan passes its own review:

- **research:** look at the actual codebase. What exists? What conventions?
  What will each task really touch? A plan written without reading the code is
  fiction.
- **plan:** draft the tasks.
- **verify:** check the plan against the spec. Does every acceptance criterion
  map to at least one task? Does any task contradict the spec? Is anything in
  the plan that the spec didn't ask for? If the plan and spec diverge, **flag it
  to the user** — don't silently let the plan win.
- **adjust:** fix and re-verify.

## Context-sized

Each plan must fit comfortably in a fresh subagent's context window (~200k
tokens) *with room to work*. If a feature's plan is too large, split it into
multiple plans per milestone. The subagent should receive the relevant spec
section + its task(s) + minimal surrounding context — never the whole project.

## Versioning & output

Save as `.claude/polis/plans/plan-<feature>-v<n>.md`. New version on material
change, latest approved is what `/polis:exec` runs.

## Precise, not padded

A task list earns nothing from verbosity. State each task in the fewest words
that leave no ambiguity. A plan that's exact and short is better than one that's
exhaustive and bloated — and it leaves more room in the subagent's window for
the actual work.
