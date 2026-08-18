---
name: context-mgmt
description: Keep coding sessions focused and compact without duplicating runtime context telemetry. On Codex, rely on native /statusline or /status for context usage. Use targeted reads, durable state, and pause/resume; subagents are not a context-percentage escape hatch.
---

# Context Management

Context is a working-memory resource, not a reason to create more agents.

## Runtime source of truth

- **Codex:** use native context information. The TUI status line can show context remaining %, context used %, and context-window size; `/status` can provide a detailed snapshot. Polis installs no Codex context-monitor hook and defines no WARNING/HIGH/CRITICAL thresholds.
- **Claude/Cursor:** use native context data when the runtime exposes it. If it does not, do not fabricate an exact percentage.

## Core discipline

1. **Shrink before spawning.** Prefer file anchors, targeted reads/searches, concise command output, git, and STATE.md over replaying broad history.
2. **Delegate for a reason.** Subagents are justified by isolation, noisy exploration, high-risk separation, or real parallel speedup — not because a percentage crossed an arbitrary line.
3. **Store durable facts, not transcripts.** STATE.md carries phase/progress/decisions/commit hashes; git carries implementation.
4. **Checkpoint at coherent boundaries.** A completed plan task is a natural commit/context boundary.
5. **When native context is getting low, reduce new input first.** Finish the current coherent task/batch if safe; otherwise checkpoint state without pretending incomplete code is complete. Then compact/start fresh and resume.
6. **Do not poll context.** Native status/footer is observational UI. Do not repeatedly invoke status commands from the model loop merely to watch a percentage.

## Codex setup recommendation

Configure `/statusline` once to include whichever native items are useful, especially `context-remaining` or `context-used`, optionally `context-window-size`, token counters, and rate limits. After that, context visibility should require zero Polis tool turns.

## Principle

The runtime owns telemetry. Polis owns workflow discipline. Keeping those responsibilities separate removes duplicate hooks, duplicate warnings, and avoidable model/tool churn.
