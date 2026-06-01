---
name: tdd
description: Use during all code execution. Activates automatically whenever production code is being written in a task. Enforces the RED -> GREEN -> REFACTOR cycle without exception: failing test first, confirm it fails for the right reason, minimal code to pass, refactor green. If production code is written before its test, delete it and restart the cycle. Adapts to the project's detected test framework.
---

# Test-Driven Development

In Polis, TDD is not a style preference — it's the law of execution. Tests come
first, always. The reason is simple: a test written after the code tends to
confirm what the code already does, including its bugs. A test written first
defines what the code *should* do, independent of how it ends up doing it.

## The cycle — RED → GREEN → REFACTOR

For every unit of behavior:

1. **RED — write a failing test.** Write the test for the behavior you're about
   to implement. Just the test.
2. **Confirm it fails for the right reason.** Run it. It must fail — and fail
   because the behavior is missing, not because of a typo, a bad import, or a
   broken harness. A test that passes immediately, or fails for the wrong
   reason, is not a valid RED.
3. **GREEN — minimal code to pass.** Write the least code that makes the test
   pass. Not the elegant version, not the general version — the minimal one.
   Resist building ahead of the test.
4. **Confirm it passes.** Run the test. Green.
5. **REFACTOR — clean up, stay green.** Improve names, remove duplication,
   tidy structure. Re-run after each change; the test stays green throughout.
6. **Commit.** The task's atomic commit happens here, with the test and code
   together.

## The hard rule

**If production code gets written before its test, delete it and start the
cycle properly.** This feels wasteful the first time and isn't — the deleted
code was written without a definition of done, and re-deriving it test-first
almost always produces something cleaner. No exceptions, no "I'll add the test
after."

## Right reason matters

Step 2 is the one people skip, and it's load-bearing. Watching the test fail for
the *correct* reason proves the test actually exercises the behavior. A test
that would pass even with the feature removed is testing nothing. Confirm the
failure mode is the absence of the behavior, then proceed.

## Framework-adaptive

Use whatever test framework the project already uses — detected by
skills/project-detect (pytest, vitest/jest, go test, cargo test, rspec, etc.).
Match the project's existing test conventions: file locations, naming, assertion
style. Don't introduce a new framework mid-project to suit a preference.

## Avoid the anti-patterns

Test behavior, not implementation. Avoid fragile tests, over-mocking, and tests
that simply mirror the code's structure. The full list and the reasoning behind
each is in references/tdd-anti-patterns.md — consult it when a test feels hard
to write, because difficulty is often a design smell, not a testing problem.
