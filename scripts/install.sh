#!/usr/bin/env bash
# ============================================================================
# Polis :: install.sh
# ----------------------------------------------------------------------------
# Installs Polis into one or more runtimes. Authored once (Claude Code format),
# converted per runtime via convert-runtime.sh, then wired into the runtime's
# real config -- idempotently, with delimited markers so --uninstall is clean.
#
# Usage:
#   bash scripts/install.sh --runtime <claude|codex|cursor|all> \
#                           --scope <user|project> [--uninstall] [--dry-run]
#
# Scope:
#   project : install into ./ (this repo) -- visible to collaborators who clone
#   user    : install into the runtime's user config dir -- all your projects
#
# Safety:
#   - Never deletes user work. --uninstall removes only Polis-marked blocks and
#     the Polis install dir it created.
#   - All edits to shared config files are bounded by POLIS markers.
#   - --dry-run prints what would happen and writes nothing.
# ============================================================================

set -euo pipefail

# --- locate self / source --------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SRC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONVERT="$SCRIPT_DIR/convert-runtime.sh"

# --- args ------------------------------------------------------------------
RUNTIME=""
SCOPE="project"
UNINSTALL=0
DRY=0

MARK_BEGIN="# >>> POLIS BEGIN >>>"
MARK_END="# <<< POLIS END <<<"

usage() {
  cat <<'USAGE'
install.sh --runtime <claude|codex|cursor|all> --scope <user|project> [--uninstall] [--dry-run]

  --runtime    which runtime(s) to target; "all" does every supported runtime
  --scope      project (this repo) or user (your global runtime config)
  --uninstall  remove Polis from the target(s)
  --dry-run    show actions without writing anything
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --runtime) RUNTIME="${2:-}"; shift 2;;
    --scope) SCOPE="${2:-}"; shift 2;;
    --uninstall) UNINSTALL=1; shift;;
    --dry-run) DRY=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "install: unknown arg: $1" >&2; usage; exit 2;;
  esac
done

[ -n "$RUNTIME" ] || { echo "install: --runtime required" >&2; usage; exit 2; }
case "$SCOPE" in user|project) ;; *) echo "install: --scope must be user|project" >&2; exit 2;; esac
[ -f "$CONVERT" ] || { echo "install: convert-runtime.sh not found next to install.sh" >&2; exit 2; }

# --- helpers ---------------------------------------------------------------
say() { echo "[polis-install] $*"; }
run() {
  if [ "$DRY" -eq 1 ]; then echo "DRY: $*"; else eval "$*"; fi
}

# Resolve the install destination root for a runtime + scope.
dest_root() {
  local rt="$1"
  if [ "$SCOPE" = "project" ]; then
    echo "$(pwd)/.polis/$rt"
  else
    case "$rt" in
      claude) echo "${HOME}/.claude/polis" ;;
      codex)  echo "${CODEX_HOME:-$HOME/.codex}/polis" ;;
      cursor) echo "${HOME}/.cursor/polis" ;;
    esac
  fi
}

# Append a marker-bounded block to a config file, idempotently.
# $1 = target config file, $2 = content
append_block() {
  local file="$1" content="$2"
  if [ "$DRY" -eq 1 ]; then echo "DRY: append POLIS block to $file"; return; fi
  mkdir -p "$(dirname "$file")"
  remove_block "$file" # ensure no duplicate
  {
    printf '%s\n' "$MARK_BEGIN"
    printf '%s\n' "$content"
    printf '%s\n' "$MARK_END"
  } >> "$file"
}

# Remove a marker-bounded block from a config file (no-op if absent).
remove_block() {
  local file="$1"
  [ -f "$file" ] || return 0
  if [ "$DRY" -eq 1 ]; then echo "DRY: remove POLIS block from $file"; return; fi
  # Delete everything between markers, inclusive.
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0==b {inblk=1; next}
    $0==e {inblk=0; next}
    !inblk {print}
  ' "$file" > "$file.polis.tmp" && mv "$file.polis.tmp" "$file"
}

# Substitute {POLIS_ROOT} -> real path in a file, in place.
subst_root() {
  local file="$1" root="$2"
  [ -f "$file" ] || return 0
  if [ "$DRY" -eq 1 ]; then echo "DRY: subst {POLIS_ROOT} -> $root in $file"; return; fi
  # Use a delimiter unlikely to appear in a path.
  sed -i "s|{POLIS_ROOT}|$root|g" "$file"
}

# ===========================================================================
# CLAUDE
# ===========================================================================
install_claude() {
  local root; root="$(dest_root claude)"
  say "claude: installing to $root (scope=$SCOPE)"
  run "bash \"$CONVERT\" --runtime claude --src \"$SRC_ROOT\" --out \"$root\""

  # Wire the statusline (separate mechanism from hooks). Claude Code reads it
  # from settings.json -> statusLine.command. We add a marker-bounded note
  # pointing at the installed statusline; the actual settings.json edit is left
  # for the user to confirm because settings.json is theirs.
  local settings
  if [ "$SCOPE" = "project" ]; then settings="$(pwd)/.claude/settings.json"; else settings="${HOME}/.claude/settings.json"; fi
  say "claude: plugin at $root. To enable the statusline, set in $settings:"
  say "        \"statusLine\": { \"type\": \"command\", \"command\": \"node $root/hooks/statusline.js\" }"
  say "        Hooks (hooks.json) and skills/commands are auto-discovered from the plugin dir."
}

# ===========================================================================
# CODEX
# ===========================================================================
install_codex() {
  local root; root="$(dest_root codex)"
  say "codex: installing to $root (scope=$SCOPE)"
  run "bash \"$CONVERT\" --runtime codex --src \"$SRC_ROOT\" --out \"$root\""

  # Substitute {POLIS_ROOT} in the emitted TOML fragments, then append them to
  # the active config.toml inside POLIS markers.
  local frag_hooks="$root/codex-config-fragments/codex.hooks.toml"
  local frag_agents="$root/codex-config-fragments/codex.agents.toml"
  subst_root "$frag_hooks" "$root"
  subst_root "$frag_agents" "$root"

  local config
  if [ "$SCOPE" = "project" ]; then config="$(pwd)/.codex/config.toml"; else config="${CODEX_HOME:-$HOME/.codex}/config.toml"; fi

  local block=""
  [ -f "$frag_hooks" ] && block="$block$(cat "$frag_hooks")"$'\n'
  [ -f "$frag_agents" ] && block="$block$(cat "$frag_agents")"$'\n'
  append_block "$config" "$block"
  say "codex: appended hooks + subagent role to $config. Skills at $root/.agents/skills, AGENTS.md at $root."
  say "codex: command hooks only -- prompt/agent handlers are skipped by Codex."
}

# ===========================================================================
# CURSOR
# ===========================================================================
install_cursor() {
  local root; root="$(dest_root cursor)"
  say "cursor: installing to $root (scope=$SCOPE)"
  run "bash \"$CONVERT\" --runtime cursor --src \"$SRC_ROOT\" --out \"$root\""

  # Cursor reads .cursor/hooks.json and .cursor/rules/ from the project (or user
  # dir). Substitute the plugin root in the hooks file and export the env var the
  # hook commands rely on.
  subst_root "$root/.cursor/hooks.json" "$root"

  # Cursor uses $CURSOR_PLUGIN_ROOT in the hook commands; record it for the user
  # since Cursor doesn't set it automatically for an out-of-tree install.
  say "cursor: hooks at $root/.cursor/hooks.json, rules at $root/.cursor/rules/."
  say "cursor: export CURSOR_PLUGIN_ROOT=$root so the hook commands resolve, or copy .cursor/ into your project."
}

# ===========================================================================
# UNINSTALL
# ===========================================================================
uninstall_runtime() {
  local rt="$1" root; root="$(dest_root "$rt")"
  say "$rt: uninstalling (scope=$SCOPE)"

  case "$rt" in
    codex)
      local config
      if [ "$SCOPE" = "project" ]; then config="$(pwd)/.codex/config.toml"; else config="${CODEX_HOME:-$HOME/.codex}/config.toml"; fi
      remove_block "$config"
      say "codex: removed POLIS block from $config"
      ;;
    claude)
      say "claude: if you added the statusLine line to settings.json, remove it manually (settings.json is yours)."
      ;;
    cursor)
      say "cursor: remove the .cursor/ entries you copied into your project, if any."
      ;;
  esac

  # Remove the Polis install dir we created (never anything else).
  if [ -d "$root" ]; then
    run "rm -rf \"$root\""
    say "$rt: removed install dir $root"
  fi
}

# ===========================================================================
# Dispatch
# ===========================================================================
targets() {
  if [ "$RUNTIME" = "all" ]; then echo "claude codex cursor"; else echo "$RUNTIME"; fi
}

for rt in $(targets); do
  case "$rt" in
    claude|codex|cursor) ;;
    *) echo "install: unknown runtime: $rt" >&2; exit 2;;
  esac
  if [ "$UNINSTALL" -eq 1 ]; then
    uninstall_runtime "$rt"
  else
    case "$rt" in
      claude) install_claude;;
      codex) install_codex;;
      cursor) install_cursor;;
    esac
  fi
done

say "done."
