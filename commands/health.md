---
description: Diagnose Polis integrity — verify the state directory, config, hook wiring, and context monitor are present and functioning. Use when something feels off or after install.
argument-hint: ""
---

# /polis:health

A self-check that confirms Polis is correctly installed and its moving parts are
intact. Read-only except for offering fixes.

## Checks

1. **State directory.** Does `.claude/polis/` exist with `STATE.md`,
   `config.json`, and the `specs/`, `plans/`, `history/` subdirectories? Report
   any missing piece and offer to create it (defer to `/polis:init` for a full
   scaffold).

2. **Config validity.** Parse `.claude/polis/config.json`. If it's malformed,
   show the parse error and offer to reset it to defaults. If it's missing,
   note that built-in defaults are in effect.

3. **Hook wiring.** Confirm the runtime knows about the Polis hooks:
   - Claude Code: `hooks.json` is discoverable and references
     `session-start.sh` and `context-monitor.js` under `${CLAUDE_PLUGIN_ROOT}`.
   - Codex: the hook fragment is present in the active `config.toml`.
   - Cursor: `.cursor/hooks.json` references the Polis scripts via
     `$CURSOR_PLUGIN_ROOT`.
   Report which runtime is active and whether the wiring resolves.

4. **Context monitor liveness.** Check for a recent `polis-ctx-*.json` bridge
   file in the OS temp dir. If present and recent, the monitor is firing. If
   absent, note that either no tools have run yet this session or the
   PostToolUse/afterFileEdit hook isn't wired — and point to the wiring check.

5. **State/git coherence.** Compare `STATE.md`'s `Last Commit` to the real
   `git rev-parse --short HEAD`. If they diverge, flag it (work happened outside
   the tracked thread) and suggest `/polis:resume-work` to reconcile.

## Output

A short checklist with ✅ / ⚠️ / ❌ per item and a one-line remedy for anything
not green. No long prose.
