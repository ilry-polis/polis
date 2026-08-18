# Polis — Agent Instructions (Codex / Cursor)

Polis is active. It enforces a spec-driven workflow with active context and
**token-efficient orchestration**. Follow it.

## Workflow

**discuss → spec → plan → exec → verify**, each gated by user approval.

- Don't jump to code. Agree design → spec → plan → execute.
- New/large project: discuss → roadmap → spec/plan/exec/verify per phase.
- Polis proposes; the user decides phase transitions and irreversible actions.

## Invocation

- Codex CLI: `$polis-discuss`, `$polis-spec`, `$polis-plan`, `$polis-exec`, etc.
- Cursor/Claude Code: `/polis:<cmd>`.

## Context discipline

- Keep the main session lean; use git/STATE.md/file anchors instead of replaying
  raw history.
- Do **not** delegate merely to satisfy a context percentage. Subagents cost
  additional model/tool work; use them when isolation, noise containment, or
  genuine parallelism pays for that cost.
- At WARNING, avoid broad output and finish the current batch. At HIGH/CRITICAL,
  checkpoint and pause/resume before starting another batch.
- Pull back agent outcomes, not transcripts.

## Execution rules

- TDD is mandatory: RED → GREEN → REFACTOR.
- Atomic commits remain per task: `[polis] T<n>: <what>`.
- Plans use coherent tasks, not 2–5 minute microtasks; default roughly 5–12
  meaningful tasks per feature phase.
- Execute up to 3 related tasks in one bounded runner batch when appropriate.
- Maximum 2 write-capable subagents concurrently by default.
- Subagents must **never spawn nested subagents**.
- Never tight-loop `wait`, `wait_agent`, `list_agents`, or status checks. One
  wait for a wave, useful coordinator work, then at most one later wait.
- Low/medium-risk batches get one combined compliance + quality review with
  targeted evidence. High-risk work keeps stronger independent scrutiny.
- Prefer one focused repair to the same runner; two failed attempts ⇒ stop and
  surface the gap instead of spawning more agents.
- Full-suite verification belongs at meaningful integration boundaries and
  `$polis-verify`, not after every microtask.

## Risk

Auth, authorization, billing/payments, security boundaries, destructive data
changes, migrations, and privacy-sensitive work default high risk.

## State

`.claude/polis/STATE.md` (or runtime-equivalent) is the durable source of truth;
specs/plans hold intent and git holds implementation. Keep STATE concise.

## Boundaries

No unilateral merges, protected-branch pushes, permission changes, destructive
deletions, or other irreversible actions. When execution stops being mechanical,
return to debugging/specification rather than multiplying agents.
