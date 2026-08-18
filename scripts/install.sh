#!/usr/bin/env bash
# ============================================================================
# Polis :: install.sh
# ============================================================================
# Installs Polis into Claude Code, Codex, Cursor, or all runtimes. Shared config
# edits are marker-bounded so reinstalls replace the previous Polis block cleanly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SRC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONVERT="$SCRIPT_DIR/convert-runtime.sh"

RUNTIME=""
SCOPE="project"
UNINSTALL=0
DRY=0

MARK_BEGIN="# >>> POLIS BEGIN >>>"
MARK_END="# <<< POLIS END <<<"

usage() {
  cat <<'USAGE'
install.sh --runtime <claude|codex|cursor|all> --scope <user|project> [--uninstall] [--dry-run]
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

say() { echo "[polis-install] $*"; }
run() {
  if [ "$DRY" -eq 1 ]; then echo "DRY: $*"; else eval "$*"; fi
}

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

remove_block() {
  local file="$1"
  [ -f "$file" ] || return 0
  if [ "$DRY" -eq 1 ]; then echo "DRY: remove POLIS block from $file"; return; fi
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0==b {inblk=1; next}
    $0==e {inblk=0; next}
    !inblk {print}
  ' "$file" > "$file.polis.tmp" && mv "$file.polis.tmp" "$file"
}

append_block() {
  local file="$1" content="$2"
  if [ "$DRY" -eq 1 ]; then echo "DRY: replace POLIS block in $file"; return; fi
  mkdir -p "$(dirname "$file")"
  remove_block "$file"
  {
    printf '%s\n' "$MARK_BEGIN"
    printf '%s\n' "$content"
    printf '%s\n' "$MARK_END"
  } >> "$file"
}

subst_root() {
  local file="$1" root="$2"
  [ -f "$file" ] || return 0
  if [ "$DRY" -eq 1 ]; then echo "DRY: subst {POLIS_ROOT} -> $root in $file"; return; fi
  sed -i "s|{POLIS_ROOT}|$root|g" "$file"
}

install_claude() {
  local root; root="$(dest_root claude)"
  say "claude: installing to $root (scope=$SCOPE)"
  run "bash \"$CONVERT\" --runtime claude --src \"$SRC_ROOT\" --out \"$root\""

  local settings
  if [ "$SCOPE" = "project" ]; then settings="$(pwd)/.claude/settings.json"; else settings="${HOME}/.claude/settings.json"; fi
  say "claude: plugin at $root. To enable the statusline, set in $settings:"
  say "        \"statusLine\": { \"type\": \"command\", \"command\": \"node $root/hooks/statusline.js\" }"
  say "        Claude hooks/skills remain runtime-managed by the plugin layout."
}

install_codex() {
  local root; root="$(dest_root codex)"
  say "codex: installing to $root (scope=$SCOPE)"
  run "bash \"$CONVERT\" --runtime codex --src \"$SRC_ROOT\" --out \"$root\""

  local frag_agents="$root/codex-config-fragments/codex.agents.toml"
  subst_root "$frag_agents" "$root"

  local config
  if [ "$SCOPE" = "project" ]; then config="$(pwd)/.codex/config.toml"; else config="${CODEX_HOME:-$HOME/.codex}/config.toml"; fi

  # Reinstall replaces the entire prior marker-bounded Polis block. This removes
  # legacy PostToolUse/SessionStart Polis hooks from older versions and writes
  # only the current custom-runner declaration.
  local block=""
  [ -f "$frag_agents" ] && block="$block$(cat "$frag_agents")"$'\n'
  append_block "$config" "$block"

  say "codex: installed Polis runner declaration to $config. No Polis context-monitor hooks are installed."
  say "codex: use native /statusline or /status for context remaining/used/window-size telemetry."
  say "codex: skills at $root/.agents/skills, AGENTS.md at $root."
}

install_cursor() {
  local root; root="$(dest_root cursor)"
  say "cursor: installing to $root (scope=$SCOPE)"
  run "bash \"$CONVERT\" --runtime cursor --src \"$SRC_ROOT\" --out \"$root\""
  subst_root "$root/.cursor/hooks.json" "$root"
  say "cursor: hooks at $root/.cursor/hooks.json, rules at $root/.cursor/rules/."
  say "cursor: export CURSOR_PLUGIN_ROOT=$root so hook commands resolve, or copy .cursor/ into your project."
}

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
      say "claude: if you added statusLine to settings.json manually, remove it manually."
      ;;
    cursor)
      say "cursor: remove any .cursor/ entries you copied into the project, if applicable."
      ;;
  esac

  if [ -d "$root" ]; then
    run "rm -rf \"$root\""
    say "$rt: removed install dir $root"
  fi
}

targets() {
  if [ "$RUNTIME" = "all" ]; then echo "claude codex cursor"; else echo "$RUNTIME"; fi
}

for rt in $(targets); do
  case "$rt" in claude|codex|cursor) ;; *) echo "install: unknown runtime: $rt" >&2; exit 2;; esac
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
