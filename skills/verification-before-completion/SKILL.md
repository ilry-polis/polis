---
name: verification-before-completion
description: Use before claiming any task, fix, or phase is "done." Activates whenever you're about to say something works, passes, is complete, or is ready. Requires concrete evidence — run the command, read the actual output — before the claim. Never report success from assumption, intention, or a subagent's self-report. Applies in exec, verify, and debugging.
---

# Verification Before Completion

"It should work now" is not "it works." The gap between those two sentences is
where most false-done claims live — and a false "done" is worse than an honest
"not yet," because it sends everyone downstream building on something broken.

This skill is a single discipline: **before you claim success, produce the
evidence.** Run the thing. Read the real output. Then claim — or don't.

## The rule

Before saying a task, fix, test, or phase is done / works / passes / is ready:

1. **Run the actual command** that would prove it — the test, the build, the
   lint, the script, the request. Not a mental simulation of it.
2. **Read the real output**, fully. Not the exit code alone, not a glance — the
   output. A suite can print "1 passed" and "3 errored" in the same run.
3. **Only then** make the claim, and state what you ran as the evidence.

If you didn't run it, you don't know it. Say "I haven't verified this yet"
instead of guessing.

## What doesn't count as verification

- **Intention** — "I wrote it to do X" is not "it does X."
- **Assumption** — "this kind of change usually works" is not evidence for *this*
  change.
- **A subagent's self-report** — when a subagent says "done, tests pass," that's a
  claim, not proof. Verify independently: run the suite yourself, read the output.
  Subagents are trusted to do the work, not to grade their own homework.
- **Partial output** — exit code 0 with warnings, "compiled" with type errors
  downstream, "passed" on the one test you ran while others are red.

## Why this is load-bearing in Polis

Polis runs work through subagents and gates each phase. Both depend on honest
completion signals:

- **In exec**, a task is done when its test is green *and you watched it go
  green* — not when the subagent says so. The two-phase review verifies
  compliance and quality against real output.
- **In verify**, the phase is done when the *full* suite is green, the lint is
  clean, and every acceptance criterion is satisfied by demonstrated behavior —
  each checked by running it, not by assuming the tasks added up.
- **In debugging**, the fix is done when the reproducing test passes and no
  regression appears — verified, not hoped.

A gate that passes on an unverified claim isn't a gate.

## The habit

Make the evidence part of the claim. Instead of "Fixed it," say "Fixed it — ran
`npm test`, 47 passed, 0 failed." The second form is checkable; the first is a
promise. Polis prefers checkable.

When you genuinely can't verify (no way to run it in this environment, a manual
step only the user can do), say so plainly and hand the verification to the user
with the exact command to run — don't paper over the gap with a confident "done."
