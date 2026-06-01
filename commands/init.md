---
description: Initialize Polis in the current project — create the state directory, scaffold STATE.md and config.json, and detect the project stack. Run once per project before using the workflow.
argument-hint: "[optional project/milestone name]"
---

# /polis:init

Set up Polis in this repository so the workflow and state tracking have a home.
Safe to run more than once — it won't clobber existing state, only fill in
what's missing.

## Steps

1. **Create the state tree** under `.claude/polis/` (or the runtime-equivalent
   path):
   - `STATE.md`
   - `config.json`
   - `specs/`, `plans/`, `history/`
   If any already exist, leave them as-is and report what was already there.

2. **Detect the stack.** Invoke the project-detection logic (skills/project-detect):
   scan for ecosystem markers, identify framework(s) and package manager, handle
   monorepos. If detection is uncertain, ask the user and record the answer.

3. **Write `config.json`** with detected stack and default toggles:
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
     }
   }
   ```

4. **Seed `STATE.md`** with an empty-but-valid skeleton:
   ```
   # Polis — Project State
   ## Current Milestone: <name from $ARGUMENTS, or "unset">
   ## Phase: discuss
   ## Progress: 0/0 tasks complete
   ## Last Commit: <current HEAD short hash + message>
   ## Previous Session: <timestamp> init
   ## Decisions:
   ## Notes:
   ## Stopped At:
   ```

5. **Confirm** with a short summary: what was created, the detected stack, and
   the suggested first step (`/polis:discuss` to start a feature).

## Guardrails

- Never overwrite an existing STATE.md or config.json; merge-fill only.
- Don't commit anything in init — setup is local until the user decides.
- If `.claude/` is gitignored (common), note that Polis state won't be tracked
  and let the user decide whether to track it.
