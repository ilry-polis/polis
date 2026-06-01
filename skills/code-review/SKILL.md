---
name: code-review
description: Use to review code against the spec and plan that defined it. Activates on /polis:review and as the review step after each task in execution. Runs a pre-review checklist, then classifies findings by severity (CRITICAL / WARNING / INFO). CRITICAL findings block merge. Reviews for spec compliance and quality, not personal style.
---

# Code Review

Review answers one question: *does this code do what the spec said, well?* It is
not a place to relitigate the design or impose personal taste — those decisions
were made in discuss and spec. Review checks compliance and quality against an
agreed standard.

## Pre-review checklist

Before reading the code for substance, confirm the basics. Any "no" is a finding
in itself:

- Do all tests pass?
- Is lint/format clean?
- No TODO/FIXME left in production code?
- No stray debug output (console.log, print, dbg!, etc.)?
- Are the spec's acceptance criteria and the plan's tasks actually covered?

If the basics fail, the review can stop there — fix those first, then review.

## Severity classification

Every finding gets a severity. This is what makes review actionable instead of
a wall of equally-weighted comments:

- 🔴 **CRITICAL** — blocks progress. Bugs, spec violations, security issues,
  data-loss risks, broken tests. **CRITICAL findings block merge.** No
  exceptions; the work isn't done until they're resolved.
- 🟡 **WARNING** — must be resolved before merge. Code smells, performance
  problems, missing error handling, fragile tests. Not a hard block in the
  moment, but the bar to merge.
- 🔵 **INFO** — suggestions. Naming, style nuance, optional refactors. Take them
  or leave them; they never block.

For each finding: state the severity, point to the exact location, say what's
wrong, and say what would fix it. A finding without a remedy is just a complaint.

## What to review against

1. **The spec** — does the code satisfy the acceptance criteria? Did it
   implement what was asked, nothing missing, nothing extra?
2. **The plan** — were the tasks done as planned, or did execution drift? Drift
   isn't automatically wrong, but it should be visible.
3. **Quality** — conventions, clarity, error handling, test integrity. Use the
   project's own standards (skills/project-detect), not imported ones.

## Verify independently — don't trust the self-report

When the code under review came from a subagent that reported "done, tests pass,"
that report is a claim, not proof. Re-run the suite and read the output yourself
(skills/verification-before-completion). A review that takes the author's word
for it isn't a review. Subagents are trusted to do the work, not to grade it.

## Output

Structure the review so it's fair and actionable:

1. **Strengths first** — briefly name what's done well. This isn't politeness for
   its own sake; it calibrates the review (the author knows you read it all) and
   keeps the critical findings from reading as a pile-on.
2. **The verdict** — mergeable, or blocked? Say it early.
3. **Findings by severity**, 🔴 CRITICAL first, then 🟡 WARNING, 🔵 INFO. Each
   with location, problem, fix.
4. **Assessment + reasoning** — the explicit close: Ready / Ready with fixes /
   Not ready, and why.

Keep each finding tight — location, problem, fix. Don't pad the review; a long
review buries the findings that matter under the ones that don't.

## Boundary

Review judges the code against the spec. If the *spec itself* turns out wrong —
the code is compliant but the requirement was misguided — that's not a review
finding, it's a signal to go back to spec with the user. Flag it as such rather
than forcing a fix at the code layer.
