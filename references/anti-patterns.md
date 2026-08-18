# Development Anti-Patterns

Recurring wrong turns Polis watches for during spec, planning, execution, and
review. The goal is correctness without avoidable orchestration cost.

## Scope & process

**Jumping to code.** Implementing before design/spec are agreed. → discuss →
spec → plan first.

**Gold-plating.** Building more than acceptance criteria require. → Implement the
contract; propose extensions separately.

**Scope creep mid-task.** Absorbing adjacent work. → Keep the task coherent and
note unrelated work separately.

**Microtask explosion.** Splitting one behavior into many 2–5 minute plan items
(test task, type task, handler task, wiring task) that must land together. This
multiplies handoffs, subagents, waits, reviews, and context rebuilds without
adding meaningful reversibility. → Plan the smallest set of coherent tasks;
default roughly 5–12 per feature phase and batch related tasks 1–3 at a time.

**Agent-per-task reflex.** Spawning a fresh agent simply because a task exists. →
Delegate only when isolation/noise/parallelism is worth another model thread;
allow trivial low-risk direct work and batch related tasks.

**Write-heavy fan-out.** Parallel agents edit overlapping or tightly coupled
areas. → Default max 2 write runners and parallelize only independent seams.

**Polling the workers.** Repeating `wait`, `wait_agent`, `list_agents`, or status
checks while nothing actionable changed. Each coordination turn can reload
context and compound token usage. → Wait once for a wave, do useful coordinator
work, then at most one later wait; surface status instead of polling indefinitely.

**Nested delegation.** A Polis task runner spawns its own agents, creating an
unbounded tree the orchestrator cannot budget. → Runner depth is exactly 1.

**Reviewer explosion.** Independent reviewers after every small low-risk task. →
Review low/medium risk once per batch; reserve stronger independent review for
high-risk work and explicit `/polis:review`.

**Suite-looping.** Re-running the entire repository suite after every small edit.
→ Targeted tests while implementing, narrow integration evidence per batch, full
suite at meaningful boundaries and `/polis:verify`.

## Code shape

**Premature abstraction.** Extracting frameworks before repeated use proves the
need. → Prefer the simplest concrete implementation.

**God objects/functions.** Too many responsibilities in one unit. → Split by
reason-to-change.

**Deep nesting.** Pyramids of conditionals. → Guard clauses and early returns.

**Magic values.** Unexplained literals. → Named constants with meaning.

**Catch-and-swallow.** Hidden failures. → Handle or propagate with context.

## State & data

**Mutable shared state.** Multiple owners mutate the same thing. → Single owner,
immutability, or explicit synchronization.

**Stringly-typed data.** Strings where types/enums belong. → Model the domain.

**Trusting input.** Assuming external data is valid. → Validate at boundaries.

## Leftovers

No debug residue, buried TODO/FIXME, or commented-out dead code. Git remembers.

## Meta-pattern

Most waste comes from an unchecked assumption: assuming more tasks means safer,
more agents means faster, or another status check means progress. Verify the
trade-off. Spend model turns on decisions and evidence, not ceremony.
