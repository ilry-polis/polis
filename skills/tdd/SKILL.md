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

## One assertion per test

A test checks one behavior. If the test name needs an "and" — `test_saves_and_emails`
— it's two tests; split it. When a single-behavior test fails, you know exactly
what broke. When a five-assertion test fails, you go hunting.

## The rationalizations — and why each is wrong

TDD discipline doesn't break by decision; it breaks by excuse. These are the
excuses, named, so you recognize them as they form — each one is the sound of the
discipline slipping:

- *"This is too simple to test."* Simple code breaks too, and the test costs
  seconds. If it's truly trivial, the test is trivial — write it.
- *"I'll add the test after."* After means never, or a test shaped to fit the
  code's bugs. The test goes first because it defines correct independently.
- *"I already wrote the code, deleting it is wasteful."* Sunk cost. The code was
  written without a definition of done; re-deriving it test-first is usually
  cleaner, not slower.
- *"TDD is dogmatic / slows me down."* The slowdown is the thinking you were
  skipping. Test-first surfaces edge cases now instead of in production.
- *"I know it works, I can see it."* Then the test passes immediately and costs
  nothing. If you can't be bothered to prove it, you don't know it.
- *"The test is hard to write."* That's the design talking, not the test. Hard-to-
  test usually means too-coupled — fix the design (see references/tdd-anti-patterns.md).

If you hear yourself thinking one of these, that's the signal to follow the
cycle, not abandon it.

## Red flags — stop and restart the cycle

Any of these means you've left TDD and need to reset to RED:

- Production code exists with no failing test behind it.
- A new test passes the moment you write it (you're testing existing behavior).
- You can't explain *why* the RED test failed.
- You're reaching for any rationalization above.

The reset is the same every time: delete the untested code, write the failing
test, watch it fail for the right reason, then proceed. Restarting feels like
losing ground; it's the opposite — it's getting back onto the only path that
ends in verified code.

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
