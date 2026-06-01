---
description: Review code against the spec and plan that defined it. Runs a pre-review checklist, then classifies findings as CRITICAL / WARNING / INFO. CRITICAL blocks merge. Checks compliance and quality, not personal style.
argument-hint: "[feature name, file path, or commit range]"
---

# /polis:review

Run a structured code review. Runs the code-review skill (skills/code-review).
Use it after a task, before a merge, or on demand against a target.

## What it does

1. Determine the target from `$ARGUMENTS` — a feature (use its spec/plan), a
   file path, or a commit range. If empty, review the uncommitted changes
   (`git diff`).
2. Run the pre-review checklist: tests pass, lint/format clean, no TODO/FIXME in
   production, no debug output, spec/plan coverage. Any "no" is itself a finding.
3. Review against the spec (acceptance criteria met, nothing missing/extra),
   the plan (drift visible), and quality (project conventions, smells, test
   integrity).
4. Classify each finding by severity and give every one a location, a problem,
   and a fix.

## Output

Lead with the verdict — mergeable or blocked. Then findings grouped by severity,
🔴 CRITICAL first, 🟡 WARNING, 🔵 INFO. CRITICAL findings block merge. Keep it
tight; don't bury the findings that matter.

## Boundary

If the code is compliant but the *spec* was wrong, that's not a review finding —
flag it as a reason to revisit the spec with the user, not a fix at the code
layer.
