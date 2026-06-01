---
description: Break an approved spec into atomic 2-5 minute tasks, each with exact file paths, expected code, a test written first, dependencies, and an unambiguous done criterion. Verified against the spec and sized to fit a fresh subagent window.
argument-hint: "[feature name]"
---

# /polis:plan

Produce the execution plan for an approved spec. Runs the writing-plans skill
(skills/writing-plans).

## What it does

1. Load the latest approved `.claude/polis/specs/spec-<feature>-v<n>.md`. If
   there's no approved spec, point to `/polis:spec`.
2. Run the quality loop — research → plan → verify → adjust:
   - Read the actual codebase before planning (a plan written without reading
     the code is fiction).
   - Break the spec into atomic tasks (ID, description, exact file paths,
     expected code, test-first, dependencies, done criterion).
   - Verify the plan against the spec: every acceptance criterion maps to a
     task; nothing contradicts the spec; nothing extra sneaks in. Flag any
     divergence to the user.
3. Keep each plan sized to fit a fresh subagent's window; split per milestone if
   too large.
4. Save as `.claude/polis/plans/plan-<feature>-v<n>.md` and advance STATE.md's
   phase to `plan` → ready for `exec`.

## Reminders

- Each task is genuinely 2–5 minutes — if it's bigger, split it.
- The test in each task is the operational definition of "done."
- Precise, not padded; a lean plan leaves room in the subagent window for the
  actual work.
