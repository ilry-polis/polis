---
description: View or change Polis preferences in .claude/polis/config.json — phase gates, TDD, context budget, and token-efficient orchestration guardrails. Changes require confirmation.
argument-hint: "[key] [value]  e.g. orchestration.maxConcurrentAgents 2"
---

# /polis:config

Inspect and adjust Polis configuration for this project. Backs onto
`.claude/polis/config.json`.

## What it does

- **No arguments:** print current config grouped as stack / context / workflow /
  orchestration and explain each toggle.
- **`<key> <value>`:** validate, show before/after, ask for confirmation, then
  save.

## Configurable keys

**workflow**
- `requireDiscuss` (bool)
- `requireSpec` (bool)
- `requirePlan` (bool)
- `tddMandatory` (bool)

**context**
- `windowTokens` (int)
- `autoCompactReserve` (float)
- `bytesPerToken` (int)
- `orchestratorTargetPct` (int)

**orchestration**
- `maxTasksPerBatch` (int, 1–3; default 3) — related tasks one runner may execute sequentially.
- `maxConcurrentAgents` (int, 1–4; default 2) — Polis-level concurrency ceiling; lower is cheaper/safer for write-heavy work.
- `maxWaitCyclesPerWave` (int, 1–3; default 2) — prevents polling loops around agent status.
- `reviewMode` (`risk-based|strict`; default `risk-based`) — risk-based batches low/medium review; strict preserves per-task stronger review when explicitly desired.
- `allowDirectLowRisk` (bool; default true) — lets the orchestrator execute trivial low-risk tasks when delegation would cost more than the work.

**stack**
- normally detected; editable when detection is wrong.

## Guardrails

- Never let config raise `maxTasksPerBatch` above 3 or `maxConcurrentAgents`
  above 4 without changing Polis source policy; these are intentionally bounded.
- `strict` review increases model/tool work; note the trade-off once, then obey.
- Validate types/enums before writing.
- Never invent unknown config keys.
