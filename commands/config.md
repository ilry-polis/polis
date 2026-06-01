---
description: View or change Polis preferences and workflow toggles stored in .claude/polis/config.json — phase gates, TDD enforcement, and context-budget tunables. Shows current values; changes require confirmation.
argument-hint: "[key] [value]  e.g. workflow.requireDiscuss false"
---

# /polis:config

Inspect and adjust Polis configuration for this project. Backs onto
`.claude/polis/config.json`.

## What it does

- **No arguments:** print the current config, grouped (stack / context /
  workflow), and explain what each toggle controls.
- **`<key> <value>`:** set a value. Confirm the change with the user before
  writing, show the before/after, then save.

## Configurable keys

**workflow** — the phase gates and rules:
- `requireDiscuss` (bool) — must run discuss before spec.
- `requireSpec` (bool) — must have an approved spec before plan.
- `requirePlan` (bool) — must have an approved plan before exec.
- `tddMandatory` (bool) — enforce the TDD cycle in execution.

**context** — the budget tunables (see references/context-budget.md):
- `windowTokens` (int) — assumed model context window.
- `autoCompactReserve` (float) — fraction reserved for auto-compact.
- `bytesPerToken` (int) — byte→token estimation factor.
- `orchestratorTargetPct` (int) — the orchestrator's budget ceiling.

**stack** — usually set by detection (skills/project-detect); editable when
detection got something wrong.

## Guardrails

- Relaxing a safety toggle (e.g. `tddMandatory false`, `requireSpec false`) is
  allowed but Polis notes the trade-off once, plainly, so the choice is
  informed — then respects it without nagging.
- Validate types before writing; a bad value (string where a bool belongs) is
  rejected with the reason, not silently saved.
- Never edit keys outside the known schema; if the user asks for an unknown key,
  ask what they intend rather than inventing config surface.
