---
description: Diagnose Polis integrity — verify state/config, runtime wiring, Codex custom runners, and state/git coherence. Codex native context UI replaces the old Polis context-monitor requirement.
argument-hint: ""
---

# /polis:health

A short self-check for Polis installation and project state.

## Checks

1. **State directory.** Confirm `.claude/polis/` exists with `STATE.md`, `config.json`, `specs/`, `plans/`, and `history/`. Missing scaffold → suggest `/polis:init`.

2. **Config validity.** Parse `.claude/polis/config.json`. Report malformed config precisely; missing config means built-in defaults apply.

3. **Runtime wiring.**
   - **Codex:** confirm Polis skills/commands and custom runner declarations are installed. A Polis `PostToolUse` context-monitor hook should **not** be required or installed. Context visibility belongs to Codex native `/statusline` and `/status`.
   - **Claude Code:** verify its configured Polis lifecycle/statusline wiring as applicable.
   - **Cursor:** verify its configured Polis rules/hooks as applicable.

4. **Codex runner guardrails.** When on Codex, confirm `polis-task-runner` resolves to its custom config, nested agents are disabled, and no duplicate/legacy Polis agent declaration is present.

5. **State/git coherence.** Compare STATE.md's `Last Commit` to real HEAD and flag drift, merge/rebase state, or unexpected uncommitted work.

## Output

Short ✅ / ⚠️ / ❌ checklist with one-line remedy for anything not green. Do not check for `polis-ctx-*` bridge liveness on Codex.
