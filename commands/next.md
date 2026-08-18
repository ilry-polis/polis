---
description: Detect the single best next Polis workflow action from durable state. Read-only; it proposes, the user decides. Codex context is observed through native /statusline or /status rather than a Polis threshold monitor.
argument-hint: ""
---

# /polis:next

Look at durable project state and propose the one most sensible next move.

## How it decides

Read STATE.md, roadmap/spec/plan state, and git. Route by priority:

1. **Pending pause** — STATE.md has a `Stopped At` breadcrumb → `/polis:resume-work`.
2. **Repository hazard** — merge/rebase/conflicts/unexpected drift → surface it before workflow progress.
3. **By phase:**
   - no design yet for active feature → `/polis:discuss`
   - new project: design + ID'd requirements approved, no roadmap → `/polis:roadmap`
   - roadmap exists, current phase not specced → `/polis:spec <phase>`
   - design approved, no spec → `/polis:spec`
   - spec approved, no plan → `/polis:plan`
   - plan approved, tasks remaining → `/polis:exec` (name next coarse task)
   - all tasks done, phase not verified → `/polis:verify`
   - phase verified, more roadmap phases → `/polis:spec <next-phase>`
   - verified, no more phases → propose next milestone
4. **Uninitialized** — no `.claude/polis/` → `/polis:init`.

## Context

Do not route based on Polis WARNING/HIGH/CRITICAL thresholds.

- On **Codex**, context remaining/used/window size is native TUI information (`/statusline` or `/status`). If the user sees context getting low, recommend checkpoint/compact/resume based on that native signal and current task safety.
- On other runtimes, use native context information when available; otherwise do not invent precision.

## Output

State current situation in one line, then the recommended next action and why in one more. It proposes; do not execute the next phase automatically.
