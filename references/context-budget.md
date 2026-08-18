# Context & Token Efficiency

Polis does not need to own runtime telemetry. Its responsibility is to keep workflow context focused and durable while avoiding unnecessary model turns.

## Source of truth by runtime

### Codex

Codex exposes native context information in its TUI/status surfaces, including:

- percentage of context remaining;
- percentage of context used;
- total context-window size;
- session token counters;
- primary/secondary usage limits when available.

Configure the native footer once with `/statusline`, or use `/status` for a detailed snapshot. **Polis installs no Codex context-monitor hook, maintains no `polis-ctx-*` bridge, and defines no WARNING/HIGH/CRITICAL thresholds on Codex.**

### Claude Code / Cursor

Use native runtime context data where available. Runtime-specific Polis UI/hooks may still exist where useful, but Polis must never fabricate an exact context percentage when the runtime does not expose one.

## Token-efficient strategy

1. **Targeted input first.** Prefer file/symbol anchors, focused searches, bounded reads, concise command output, git, and STATE.md.
2. **Coarse plans.** Aim for roughly 3–7 coherent capability tasks per feature phase, not file-by-file microtasks.
3. **Delegate for a reason.** Use a subagent for isolation, noisy exploration, high-risk separation, or real parallel speedup — not because a task exists or a context percentage changed.
4. **Bound orchestration.** Default max 2 write-capable runners; no nested agents; no polling loops.
5. **Reuse useful local context.** At most two closely related coarse tasks may share one runner when that clearly reduces repeated setup.
6. **Verify at meaningful boundaries.** Behavior-focused evidence during execution; holistic verification at integration boundaries and `/polis:verify`.
7. **Durable state beats transcript replay.** Git stores implementation; STATE.md stores phase, progress, decisions, blockers, and commit hashes.
8. **When native context gets low, checkpoint rather than fan out.** Finish a safe coherent boundary or record exact incomplete state, then compact/start fresh and resume.

## Principle

**The runtime owns telemetry. Polis owns workflow discipline.** Duplicating native context meters with post-tool hooks creates overhead without improving the engineering result.
