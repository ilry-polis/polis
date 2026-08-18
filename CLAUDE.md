# Polis — Claude Code Instructions

Polis is active. It enforces spec-driven development with context-aware,
**token-efficient orchestration**.

## Workflow

**discuss → spec → plan → exec → verify**, each gated by user approval. New/large
projects add roadmap between discuss and spec.

- Don't jump to code.
- Use coherent tasks, not arbitrary 2–5 minute microtasks.
- Polis proposes; the user decides phase transitions and irreversible actions.

## Context discipline

- Keep the orchestrator focused with file anchors, targeted reads, concise
  command output, git, and STATE.md.
- Subagents cost their own model/tool work. Delegate when isolation, noisy work,
  or genuine parallelism justifies that cost — not merely because context crossed
  a percentage.
- At WARNING reduce broad input and finish the current batch. At HIGH/CRITICAL,
  checkpoint and pause/compact/resume before starting another batch.
- Pull back outcomes, never full agent transcripts.

## Execution rules

- TDD mandatory: RED → GREEN → REFACTOR.
- One atomic commit per task: `[polis] T<n>: <what>`.
- Default plan target: roughly 5–12 meaningful tasks per feature phase.
- One runner may execute 1–3 related tasks sequentially; atomicity remains per
  task.
- Maximum 2 write-capable runners concurrently by default.
- No nested subagents from a Polis task runner.
- Never tight-loop agent status/wait checks. Wait once for a wave, do useful
  coordinator work, then at most one later wait.
- Low/medium-risk batches: one combined compliance + quality review with targeted
  evidence. High-risk work gets stronger scrutiny.
- Full suite at meaningful integration boundaries and `/polis:verify`, not after
  every microtask.
- Prefer one focused repair to the same runner; two failed attempts ⇒ stop and
  surface the gap.

## Commands

`/polis:init` `/polis:discuss` `/polis:roadmap` `/polis:spec` `/polis:plan`
`/polis:exec` `/polis:review` `/polis:verify` `/polis:status` `/polis:next`
`/polis:health` `/polis:config` `/polis:pause-work` `/polis:resume-work`

## State & boundaries

`.claude/polis/STATE.md` is durable phase/progress state; specs/plans hold intent;
git holds implementation. No unilateral merges, protected-branch pushes,
permission changes, or destructive actions. When execution stops being
mechanical, return to debugging/specification rather than multiplying agents.
