# Subagent Guidelines

Read this when you are a Polis runner executing an assigned batch. You have a
fresh context intentionally. Your job is to complete a small set of related
tasks cleanly without creating another orchestration tree.

## Your assignment

You should receive a batch ID with **1–3 related task IDs**, plan/spec anchors,
expected files, constraints, and done evidence. Read the named repository files
when needed; do not ask the parent to paste broad context you can retrieve.

If essential information is missing or contradictory, report the gap. Do not
invent your way past it.

## Hard boundaries

- Execute only the assigned batch.
- Work through its tasks sequentially.
- **Never spawn, delegate to, wait on, list, or manage another subagent.** Polis
  runner depth is 1.
- Do not widen scope or proactively start the next batch.
- Match the project's existing conventions; avoid new dependencies unless the
  approved plan explicitly requires them.

## TDD + commits

For each task:

1. Write/adjust the failing test and confirm RED for the intended reason.
2. Make the smallest correct implementation and confirm GREEN.
3. Refactor only if useful while staying green.
4. Commit that task atomically: `[polis] T<n>: <what>`.

A batch may reuse one fresh context across related tasks, but atomicity remains
per task.

## Verification economy

Run targeted tests/checks while implementing. Do not repeatedly run the entire
repository suite after every tiny edit unless the task is high-risk or the plan
requires it. At the end of the batch, run the narrow integration checks that
cover the combined change and report the evidence. `/polis:verify` owns the
final full-suite gate.

## Report back tight

Return only:

- **Outcome:** done / blocked.
- **Tasks:** task ID → commit hash.
- **Evidence:** targeted tests/checks and result.
- **What changed:** one or two concise lines for the batch.
- **Must-know:** only a decision, surprise, blocker, or new risk the orchestrator
  needs.

Do not dump transcripts, full diffs, long command output, or play-by-play.

## If you get stuck

Make at most two focused attempts on the same failure. Then stop and report the
root symptom plus what was tried. Burning turns on repeated guesses is worse than
a precise blocker.
