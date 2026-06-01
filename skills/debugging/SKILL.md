---
name: debugging
description: Use whenever something is broken — a failing test, a bug, unexpected behavior, an error you don't understand. Activates during exec and verify when work stops being mechanical. Enforces root-cause investigation BEFORE any fix, single-hypothesis testing, fixing the source not the symptom, and stopping to question the design after repeated failed fixes. Systematic beats guessing, always.
---

# Systematic Debugging

When something breaks, the instinct is to try a fix and see if it works. That
instinct is the slow path. Guessing — changing things to see what happens —
feels fast but thrashes: each random change can introduce new problems while
hiding the real one. Systematic debugging is faster precisely because it refuses
to guess. Understand first, then fix once.

This skill activates the moment work stops being mechanical: a test won't go
green, behavior surprises you, an error appears you can't immediately explain.

## The iron rule

**No fix before you understand the root cause.** Not a "quick fix to see," not a
"let me just try changing this." Until you can state *why* the bug happens, any
change you make is a guess, and guesses stack into a mess. Investigation comes
first, every time.

## The four phases

### Phase 1 — Root-cause investigation (mandatory, before any fix)

- **Read the full error.** The whole message and stack trace, not the first line.
  The answer is often three frames down.
- **Reproduce it consistently.** A bug you can't reproduce reliably, you can't
  verify you fixed. Find the exact steps that trigger it every time.
- **Check what changed recently.** `git diff`, recent commits — most bugs are in
  what just moved.
- **Instrument the boundaries.** Log or inspect at the edges of the component:
  what goes in, what comes out. Narrow where the bad value first appears.
- **Trace backward.** From the bad value, walk back toward its origin — where did
  it first become wrong? That point, not where it blew up, is the root.

You leave Phase 1 only when you can say, concretely, where the bug originates.

### Phase 2 — Pattern analysis

- Find a **working example** of the same kind of thing (another call site, a
  similar function, the same pattern elsewhere that works).
- **Read the references completely** — not a skim. The detail you skip is usually
  the one that matters.
- **Enumerate every difference** between the working case and the broken one. The
  bug lives in one of those differences.

### Phase 3 — Hypothesis and test

- Write down **one specific hypothesis**: "X happens because Y." Specific, not
  "maybe it's the config."
- **Test it minimally** — change one variable, the smallest thing that would
  confirm or kill the hypothesis.
- If the hypothesis is **wrong, form a new one.** Do **not** stack fixes — undo
  the failed change before trying the next. Stacked half-fixes are how a one-line
  bug becomes a four-hour mess.

### Phase 4 — Implementation

- Write a **failing test that reproduces the bug** first (this uses skills/tdd —
  the bug becomes a RED test). Now the fix has a definition of done.
- **Fix the root cause, not the symptom.** Patching where it blew up leaves the
  real cause to resurface elsewhere.
- **Verify no regressions** — the new test passes and the existing suite stays
  green.

## Hard rules

- No fix before Phase 1 is complete.
- One change at a time — never two variables at once.
- Fix at the source, not the symptom.
- **3+ failed fixes ⇒ stop.** Repeated failure means you're solving the wrong
  problem — the issue is probably architectural, not local. Don't try a fourth
  patch; step back and question the design. (This is the debugging echo of the
  Polis rule: when work stops being mechanical, an earlier phase has a gap.)

## Named techniques

- **Root-cause tracing** — walk backward from the bad value to its origin, rather
  than forward from where it crashed.
- **Defense in depth** — once the root cause is fixed, add validation at the
  layers that should have caught it, so the class of bug can't recur silently.
- **Condition-based waiting** — for flaky timing bugs, replace fixed timeouts with
  polling on the actual condition; arbitrary sleeps hide races, they don't fix
  them.
- **Polluter bisection** — when a test passes alone but fails in the suite,
  bisect the test order to find which earlier test pollutes shared state.

## Red flags — you're guessing, restart the method

If you catch yourself thinking any of these, stop and go back to Phase 1:

- "Quick fix for now, I'll understand it later."
- "Let me just try changing X and see what happens."
- "One more attempt." (especially after several)
- Each fix you make surfaces a new problem somewhere else (classic symptom-patching).

Systematic is not slower. It's the only path that ends.
