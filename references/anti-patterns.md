# Development Anti-Patterns

The recurring wrong turns Polis watches for during spec, execution, and review.
Each entry names the pattern, why it's harmful, and the move that avoids it.
This is the general set; a spec's own "What NOT to do" section lists the ones
specific to its feature.

## Scope & process

**Jumping to code.** Writing implementation before the design and spec are
agreed. The fast path that produces the wrong thing. → Run discuss → spec →
plan first; code is the last step, not the first.

**Gold-plating.** Building more than the spec asked because it "might be useful."
Unrequested generality is unrequested risk and unrequested context cost.
→ Implement exactly what the acceptance criteria require; propose extensions
separately.

**Scope creep mid-task.** Letting a task absorb adjacent work because you're
"already in there." → One task, one change, one commit. Note the adjacent work
as a future task.

**Silent divergence.** Execution drifts from the plan, or the plan from the
spec, without anyone flagging it. → Divergence is allowed but must be visible;
surface it to the user.

## Code shape

**Premature abstraction.** Extracting a framework from a single use case. The
abstraction encodes guesses about uses that don't exist yet. → Wait for the
third occurrence before abstracting; duplication is cheaper than the wrong
abstraction.

**God objects / functions.** One unit that knows and does everything. Impossible
to test, reason about, or change safely. → Single responsibility; split by
reason-to-change.

**Deep nesting.** Pyramids of conditionals. → Guard clauses and early returns;
flatten the happy path.

**Magic values.** Unexplained literals scattered through code. → Named constants
with the meaning attached.

**Catch-and-swallow.** Catching errors and doing nothing, hiding failures until
they surface somewhere worse. → Handle, or propagate with context; never
silence.

## State & data

**Mutable shared state.** Multiple owners mutating the same thing, ordering bugs
waiting to happen. → Single owner, or immutable data, or explicit synchronization.

**Stringly-typed data.** Using strings where a type or enum belongs, pushing
errors to runtime. → Model the domain with real types.

**Trusting input.** Assuming external data is well-formed. → Validate at the
boundary; treat everything outside as untrusted.

## Leftovers & hygiene

**Debug residue.** console.log / print / dbg! shipped to production. → Remove
before commit; the pre-review checklist catches these.

**TODO/FIXME in production.** Deferred work that becomes permanent. → Resolve, or
file it as a real task; don't bury it in a comment.

**Commented-out code.** Dead code kept "just in case." Git already remembers.
→ Delete it.

## The meta-pattern

Most anti-patterns share a root: **acting on an assumption instead of checking
it.** Assuming the design, assuming the abstraction will be needed, assuming the
input is valid, assuming the plan still fits. When something feels like it needs
a guess, that's the moment to verify instead — read the code, ask the user, write
the test.
