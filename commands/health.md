---
description: Diagnose Polis integrity — verify state/config, runtime wiring, duplicate Codex skills, custom runners, and state/git coherence. Codex native context UI replaces the old Polis context monitor.
argument-hint: ""
---

# /polis:health

A short self-check for Polis installation and project state.

## Checks

1. **State directory.** Confirm `.claude/polis/` exists with `STATE.md`, `config.json`, `specs/`, `plans/`, and `history/`. Missing scaffold → suggest `$polis-init` on Codex or the runtime-equivalent init command.

2. **Config validity.** Parse `.claude/polis/config.json`. Report malformed config precisely; missing config means built-in defaults apply.

3. **Codex skill deduplication.** On Codex, inspect the skill roots that actually exist, especially:
   - `$HOME/.agents/skills`
   - `$CODEX_HOME/polis/.agents/skills` (or `$HOME/.codex/polis/.agents/skills`)
   - project `.agents/skills` / installed plugin roots when present.

   Read only frontmatter `name:` values. Report any duplicate `polis-*` name with every path. There should be **exactly one discoverable copy of each explicit `$polis-*` entrypoint**. Also flag legacy `.agents/commands/polis-*` artifacts because Codex 0.5.1+ uses skills for `$` entrypoints, not a parallel commands surface.

4. **Runtime wiring.**
   - **Codex:** confirm the current Polis plugin skill tree and custom runner declaration resolve. Polis `PostToolUse`/`SessionStart` context-monitor hooks should not be installed. Context visibility belongs to native `/statusline` and `/status`.
   - **Claude Code:** verify its configured Polis lifecycle/statusline wiring as applicable.
   - **Cursor:** verify its configured Polis rules/hooks as applicable.

5. **Codex runner guardrails.** Confirm `polis-task-runner` resolves to its custom config, nested agents are disabled, and no duplicate/legacy agent declaration is present.

6. **State/git coherence.** Compare STATE.md's `Last Commit` to real HEAD and flag drift, merge/rebase state, or unexpected uncommitted work.

## Output

Short ✅ / ⚠️ / ❌ checklist with one-line remedy. For duplicate skills, print the duplicate name and exact paths. Do not load full SKILL.md bodies merely to check duplication; frontmatter names are enough.
