---
name: tdd
description: Use during code execution for behavior changes. Enforces RED -> GREEN -> REFACTOR at the capability/behavior boundary, without manufacturing redundant tests for mechanical edits. Reuse or extend existing tests when they already own the behavior; use deterministic non-test checks for non-behavioral changes.
---

# Test-Driven Development

Polis uses TDD to prove behavior, not to maximize test count. The unit of TDD is
a **behavior or capability**, not a file edit, helper, type, config line, or
implementation step.

## When RED -> GREEN -> REFACTOR is required

Use a real RED → GREEN → REFACTOR cycle when a task introduces or changes
observable behavior, including:

- business/domain rules;
- API contracts and validation behavior;
- user-visible interactions;
- authorization/security decisions;
- state transitions;
- bug fixes where a regression test can reproduce the failure;
- data transformations whose correctness is behavioral.

For one coherent capability, prefer the **smallest useful set of tests** that
proves the behavior. Do not create one test per touched file or implementation
step.

## Reuse before adding

Before writing a new test:

1. Find the test that already owns this behavior or boundary.
2. Extend it if that gives clear coverage without making it brittle.
3. Add a new test only when it represents a distinct behavior, regression, edge
   case, or risk that the existing suite cannot express cleanly.

A test suite that proves the contract with 4 tests is better than one that proves
the same thing with 20 near-duplicates.

## Mechanical changes do not require artificial RED

Do **not** manufacture a failing unit test merely because a task includes:

- types/interfaces generated or aligned to an existing contract;
- imports/exports or dependency wiring;
- formatting/renaming with no behavior change;
- configuration changes best validated by config/schema parsing;
- migrations whose correctness is better proven by migration/schema checks;
- build/tooling changes best validated by build/type/lint commands;
- glue code already exercised by the owning integration/behavior test.

Use the strongest cheap deterministic evidence instead: existing targeted tests,
typecheck, lint, build, schema/migration validation, contract tests, or a focused
integration check.

## The behavior cycle

For a behavior that needs TDD:

1. **RED** — write or extend the test that expresses the missing/changed behavior.
2. Run the **targeted** test and confirm it fails for the intended reason.
3. **GREEN** — implement the complete coherent behavior, including the related
   files needed to make that slice work.
4. Run the targeted evidence until green.
5. **REFACTOR** — clean the implementation while keeping evidence green.
6. Commit the coherent task.

Do not restart RED/GREEN merely because implementation touched another file in
the same capability.

## Bug fixes

For a reproducible bug, prefer one regression test that fails before the fix and
passes after it. Do not add multiple tests that restate the same failure at every
layer unless the layers represent independent contracts or risk boundaries.

## High-risk boundaries

Auth, authorization, payments/billing, security, privacy, destructive data
operations, and critical migrations justify stronger automated evidence. Even
there, optimize for **coverage of risk**, not raw test count.

## Framework-adaptive

Use the project's existing test framework and conventions. Do not introduce a
new framework simply to satisfy Polis. Test behavior rather than implementation
structure, avoid over-mocking, and keep tests stable under refactoring.

## Principle

**No unproven behavior, no redundant ceremony.** If behavior changes, prove it.
If behavior does not change, validate the actual failure mode of the mechanical
change instead of inventing a test that adds no information.
