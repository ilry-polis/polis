---
name: subagent-dispatch
description: Use whenever delegating work to a subagent during execution. Defines what context to package (and what to withhold), how to brief a fresh-context subagent so it can act without the chat history, and how to review and integrate what it returns without polluting the orchestrator's window. Activates during /polis:exec and whenever heavy work should leave the orchestrator.
---

# Subagent Dispatch

Subagents are how Polis keeps the orchestrator lean: the expensive work runs in
a fresh window and only the conclusion comes back. Getting the handoff right is
what makes that trade pay off. A badly briefed subagent guesses; a badly
reviewed return pollutes the orchestrator. This skill covers both ends.

## What to send (the briefing)

A subagent has **none** of your conversation history. Brief it as you would a
competent contractor who just walked in:

- **The task** — its full definition from the plan: ID, description, file paths,
  expected code, the test, the done criterion.
- **The relevant spec section** — only the part that governs this task, not the
  whole spec.
- **Minimal surrounding context** — the conventions, the adjacent interfaces it
  must match, the location of things it'll touch. Enough to act correctly.
- **The standard of done** — TDD required, atomic commit expected, what
  "compliant + quality" means here.

## What to withhold

- The full chat transcript. The subagent doesn't need how you got here.
- The whole codebase. Point it at what's relevant; let it read more if it must.
- Other tasks' details, unless this task depends on them.
- Your reasoning narrative. Give it the decision, not the deliberation.

The discipline cuts both ways: sending too little makes it guess, sending too
much defeats the purpose. The plan's per-task fields exist precisely so this
briefing is mostly copy-paste, not re-derivation.

## Reviewing the return

When the subagent reports back, run the two-phase review (see
skills/executing-plans):

1. **Compliance** — did it do exactly what was asked? Spec criteria met?
2. **Quality** — conventions, smells, dead code, debug output, fragile tests?

If it fails either phase, dispatch a focused fix — describe the specific defect,
don't re-send the whole task from scratch.

## Integrating without polluting

This is the part that's easy to get wrong. When you accept a subagent's work:

- Pull back the **outcome**, not the transcript: what was done, the commit hash,
  any decision or surprise worth recording.
- Write that outcome to STATE.md.
- Do **not** echo the subagent's full output into the orchestrator. A one-to-two
  line summary is the right size. The code lives in git; the orchestrator only
  needs to know it's there and that it passed review.

If you find yourself reading large subagent outputs verbatim into the main
window, stop — that's the exact failure mode the architecture exists to prevent.

## Parallel dispatch

When dispatching an independent wave, brief each subagent the same way, then
review returns one at a time. Watch for integration seams — two subagents that
each passed in isolation can still conflict where their work meets. Resolve the
seam before the next wave.
