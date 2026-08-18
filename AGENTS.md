# Polis — Agent Instructions (Codex / Cursor)

Polis is active. It enforces a spec-driven workflow with **token-efficient orchestration**.

## Workflow

**discuss → spec → plan → exec → verify**, each gated by user approval.

- Don't jump to code. Agree design → spec → plan → execute.
- New/large project: discuss → roadmap → spec/plan/exec/verify per phase.
- Polis proposes; the user decides phase transitions and irreversible actions.

## Invocation

- Codex CLI: `$polis-discuss`, `$polis-spec`, `$polis-plan`, `$polis-exec`, etc.
- Cursor: `/polis:<cmd>`.

## Context discipline

- Keep the main session lean with file anchors, targeted reads, concise command output, git, and STATE.md.
- **Codex:** use the native TUI context data. `/statusline` can show context remaining/used/window size continuously; `/status` can be used for a detailed snapshot. Polis installs no Codex context-monitor hook and defines no WARNING/HIGH/CRITICAL thresholds of its own.
- **Cursor:** use native context information when available; otherwise manage context qualitatively. Do not fabricate a percentage.
- Do not delegate merely because context is getting large. Subagents cost additional model/tool work; delegate only when isolation, noise containment, high-risk separation, or genuine parallelism justifies it.
- When context is getting low, finish the current coherent task/batch if safe, checkpoint durable state, then compact/start a fresh session and resume.
- Pull back agent outcomes, not transcripts.

## Execution rules

- Behavior-focused TDD: RED → GREEN → REFACTOR for observable behavior changes; do not manufacture tests for mechanical edits.
- Atomic commits remain per plan task: `[polis] T<n>: <what>`.
- Plans use coarse coherent capability tasks, normally roughly 3–7 per feature phase.
- One runner may execute at most two closely related tasks when reuse of local context is valuable.
- Maximum 2 write-capable subagents concurrently by Polis policy.
- Subagents must never spawn nested subagents.
- Never tight-loop `wait`, `wait_agent`, `list_agents`, or status checks. Wait once for a wave, do useful coordinator work, then at most one later wait.
- Low/medium-risk work gets one concise compliance + quality review at a useful boundary. High-risk work keeps stronger independent scrutiny.
- Prefer one focused repair to the same runner; two failed attempts ⇒ stop and surface the gap instead of spawning more agents.
- Full-suite verification belongs at meaningful integration boundaries and `$polis-verify`, not after every task.

## Risk

Auth, authorization, billing/payments, security boundaries, destructive data changes, migrations, and privacy-sensitive work default high risk.

## State

`.claude/polis/STATE.md` (or runtime-equivalent) is the durable source of truth; specs/plans hold intent and git holds implementation. Keep STATE concise.

## Boundaries

No unilateral merges, protected-branch pushes, permission changes, destructive deletions, or other irreversible actions. When execution stops being mechanical, return to debugging/specification rather than multiplying agents.
