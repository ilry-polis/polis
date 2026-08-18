---
description: Initialize Polis in the current project — scaffold state/config, detect the stack, and seed token-efficient orchestration defaults. Safe to rerun without clobbering state.
argument-hint: "[optional project/milestone name]"
---

# /polis:init

Set up Polis in this repository.

## Steps

1. Create the runtime-equivalent Polis state tree:
   - `STATE.md`
   - `config.json`
   - `specs/`, `plans/`, `history/`
   Existing files are merge-filled, never overwritten.

2. Detect the stack using `skills/project-detect`. Handle monorepos and record
   uncertainty rather than guessing.

3. Seed missing `config.json` values:

```json
{
  "stack": { "...": "from detection" },
  "context": {
    "windowTokens": 200000,
    "autoCompactReserve": 0.165,
    "bytesPerToken": 4,
    "orchestratorTargetPct": 40
  },
  "workflow": {
    "requireDiscuss": true,
    "requireSpec": true,
    "requirePlan": true,
    "tddMandatory": true
  },
  "orchestration": {
    "maxTasksPerBatch": 2,
    "maxConcurrentAgents": 2,
    "maxWaitCyclesPerWave": 2,
    "reviewMode": "risk-based",
    "allowDirectLowRisk": true
  }
}
```

Planning defaults are intentionally coarse: approximately **3–7 coherent
capability tasks per feature phase**, not 2–5 minute microtasks. Execution may
batch at most two closely related tasks when reuse of local context is valuable.

4. Seed `STATE.md` with current milestone, phase, progress, HEAD, timestamp,
   decisions, notes, and stopped-at breadcrumb.

5. Confirm what was created/detected and suggest `/polis:discuss`.

## Guardrails

- Never overwrite STATE.md/config.json; merge-fill only missing keys.
- Don't commit init setup unless the user asks.
- If the state directory is gitignored, note it and let the user decide.
