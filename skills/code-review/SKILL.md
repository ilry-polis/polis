---
name: code-review
description: Review code against the approved spec/plan with evidence. During execution, review at the batch boundary and scale scrutiny by risk; reserve independent two-phase review for high-risk work or explicit /polis:review.
---

# Code Review

Review answers: *does this code do what the approved spec said, well?* Review
must catch real defects without turning every tiny task into another expensive
agent workflow.

## Execution review policy

During `/polis:exec`:

- **Low/medium-risk batch:** one combined compliance + quality pass after the
  batch, backed by targeted tests and relevant lint/type checks. Do not spawn a
  separate reviewer for each task by default.
- **High-risk task/batch:** use stronger independent scrutiny. Auth,
  authorization, billing/payments, security boundaries, destructive data work,
  migrations, and privacy-sensitive flows default high risk.
- **Explicit `/polis:review`:** perform the full review requested by the user,
  but parallel reviewers are optional, not automatic.

## Pre-review checklist

Before substantive review:

- Targeted tests for changed behavior pass.
- Relevant lint/format/type checks are clean.
- No TODO/FIXME or stray debug output was introduced.
- Acceptance criteria covered by the batch are accounted for.

Run the full suite only at a meaningful integration boundary, for high-risk work
where breadth is necessary, or during `/polis:verify`. Re-running the full suite
after every microchange is not evidence-efficient.

## Severity

- 🔴 **CRITICAL** — blocks progress: bugs, spec violations, security issues,
  data-loss risks, broken required tests.
- 🟡 **WARNING** — resolve before merge: material code smells, performance risks,
  missing error handling, fragile tests.
- 🔵 **INFO** — optional suggestions; never block.

For each finding: location, concrete problem, and smallest defensible fix.

## What to review against

1. **Spec** — acceptance criteria, nothing missing/extra.
2. **Plan/batch** — implementation stayed within approved scope.
3. **Quality** — conventions, clarity, error handling, test integrity.

## Repair policy

Prefer one focused follow-up to the same implementation runner while its local
context is useful. Do not spawn a fresh fix agent for every finding. Two failed
repair attempts on the same defect ⇒ stop and surface the gap.

## Independent evidence

A runner's "tests pass" is a claim, not proof. The orchestrator should verify the
important evidence itself, but do so at the correct boundary: targeted checks per
batch and holistic checks at `/polis:verify`.

## Output

1. Verdict: ready / ready with fixes / blocked.
2. Findings by severity.
3. Evidence checked.
4. Any spec/plan mismatch that should return to an earlier phase.

Keep the review tight. Length is not rigor.
