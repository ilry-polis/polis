#!/usr/bin/env bash
# ============================================================================
# Polis :: session-start.sh
# ----------------------------------------------------------------------------
# Bootstraps Polis at the start of a session. Designed to run as:
#   - Claude Code:  SessionStart hook  (CAN inject context via additionalContext)
#   - Codex CLI:    a SessionStart-equivalent command hook
#   - Cursor:       invoked from a beforeSubmitPrompt hook on first prompt
#
# WHY THIS FILE MATTERS:
#   PostToolUse (context-monitor.js) is a sensor: it measures but cannot speak
#   to the model. SessionStart is the voice: it CAN inject text into the model's
#   context. So this script is where Polis tells the agent (a) that the Polis
#   workflow is active and (b) what the current context budget looks like.
#
# OUTPUT CONTRACT:
#   Claude Code reads stdout as JSON when the key "additionalContext" is present
#   under a "hookSpecificOutput" object for SessionStart. We emit that. For
#   runtimes that just want plain text, the same content is human-readable.
#
# SAFETY: always exits 0. Never blocks a session from starting.
# ============================================================================

set -u

# --- Resolve the plugin root across runtimes -------------------------------
# Claude Code sets CLAUDE_PLUGIN_ROOT; Cursor uses CURSOR_PLUGIN_ROOT; Codex
# scripts can export POLIS_ROOT. Fall back to this script's own directory.
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${CURSOR_PLUGIN_ROOT:-${POLIS_ROOT:-$(dirname "$SELF_DIR")}}}"

# --- Resolve the project dir -----------------------------------------------
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_FILE="$PROJECT_DIR/.claude/polis/STATE.md"

# --- Read the latest context estimate from the bridge file (if any) ---------
# The bridge is per-session in the OS temp dir. We don't know the session id
# here for certain, so we read the most recently modified polis-ctx-*.json.
TMPDIR_RESOLVED="${TMPDIR:-/tmp}"
CTX_LINE=""
LATEST_BRIDGE="$(ls -t "${TMPDIR_RESOLVED%/}"/polis-ctx-*.json 2>/dev/null | head -n1 || true)"
if [ -n "${LATEST_BRIDGE:-}" ] && [ -f "$LATEST_BRIDGE" ]; then
  # Pull percent_used and threshold without requiring jq (vanilla grep/sed).
  PCT="$(grep -o '"percent_used"[^,]*' "$LATEST_BRIDGE" 2>/dev/null | grep -o '[0-9]\+' | head -n1)"
  THR="$(grep -o '"threshold"[^,]*' "$LATEST_BRIDGE" 2>/dev/null | sed 's/.*"threshold"[^"]*"\([^"]*\)".*/\1/' )"
  if [ -n "${PCT:-}" ]; then
    CTX_LINE="Context budget (estimate): ~${PCT}% of usable window (${THR:-OK})."
  fi
fi

# --- Detect a prior pause so resume guidance can be offered ----------------
RESUME_LINE=""
if [ -f "$STATE_FILE" ] && grep -q "Stopped At" "$STATE_FILE" 2>/dev/null; then
  RESUME_LINE="A prior pause was detected in STATE.md. Consider /polis:resume-work to restore context before starting new work."
fi

# --- Compose the injected context ------------------------------------------
read -r -d '' CONTEXT <<EOF || true
[Polis active] Spec-driven workflow with isolated subagents is in effect.

Operating rules for this session:
- Do not jump to code. Follow discuss -> spec -> plan -> exec -> verify; each phase needs the user's approval to advance.
- Keep this orchestrator context lean (target <40% of usable window). Heavy work runs in fresh-context subagents.
- TDD is mandatory in execution: RED -> GREEN -> REFACTOR, one atomic commit per task.
- If the context monitor reports HIGH, finish and commit the current task only. If CRITICAL, run /polis:pause-work.
${CTX_LINE:+- $CTX_LINE}
${RESUME_LINE:+- $RESUME_LINE}
EOF

# --- Emit. Prefer Claude Code's structured SessionStart contract. ----------
# We hand-roll the JSON to avoid any dependency. Newlines are escaped.
ESCAPED="$(printf '%s' "$CONTEXT" | sed ':a;N;$!ba;s/\\/\\\\/g;s/"/\\"/g;s/\n/\\n/g')"
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$ESCAPED"

exit 0
