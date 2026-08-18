#!/usr/bin/env bash
# Polis installer. Marker-bounded shared config + safe legacy migration.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SRC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONVERT="$SCRIPT_DIR/convert-runtime.sh"
RUNTIME=""; SCOPE="project"; UNINSTALL=0; DRY=0
MARK_BEGIN="# >>> POLIS BEGIN >>>"; MARK_END="# <<< POLIS END <<<"

usage() { echo "install.sh --runtime <claude|codex|cursor|all> --scope <user|project> [--uninstall] [--dry-run]"; }
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
[ -n "$RUNTIME" ] || { echo "install: --runtime required" >&2; exit 2; }
case "$SCOPE" in user|project) ;; *) echo "install: --scope must be user|project" >&2; exit 2;; esac
[ -f "$CONVERT" ] || { echo "install: convert-runtime.sh not found" >&2; exit 2; }

say() { echo "[polis-install] $*"; }
run() { if [ "$DRY" -eq 1 ]; then echo "DRY: $*"; else eval "$*"; fi; }

dest_root() {
  local rt="$1"
  if [ "$SCOPE" = "project" ]; then echo "$(pwd)/.polis/$rt"; return; fi
  case "$rt" in
    claude) echo "${HOME}/.claude/polis";;
    codex) echo "${CODEX_HOME:-$HOME/.codex}/polis";;
    cursor) echo "${HOME}/.cursor/polis";;
  esac
}

remove_block() {
  local file="$1"; [ -f "$file" ] || return 0
  if [ "$DRY" -eq 1 ]; then echo "DRY: remove POLIS block from $file"; return; fi
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '$0==b{inblk=1;next}$0==e{inblk=0;next}!inblk{print}' "$file" > "$file.polis.tmp" && mv "$file.polis.tmp" "$file"
}
append_block() {
  local file="$1" content="$2"
  if [ "$DRY" -eq 1 ]; then echo "DRY: replace POLIS block in $file"; return; fi
  mkdir -p "$(dirname "$file")"; remove_block "$file"
  { printf '%s\n' "$MARK_BEGIN"; printf '%s\n' "$content"; printf '%s\n' "$MARK_END"; } >> "$file"
}
subst_root() {
  local file="$1" root="$2"; [ -f "$file" ] || return 0
  if [ "$DRY" -eq 1 ]; then echo "DRY: subst {POLIS_ROOT} -> $root in $file"; return; fi
  # Portable across BSD/macOS and GNU environments; avoids incompatible sed -i.
  awk -v r="$root" '{ gsub(/\{POLIS_ROOT\}/, r); print }' "$file" > "$file.polis.tmp" && mv "$file.polis.tmp" "$file"
}

# Conversion uses copy semantics, so stale files from older versions otherwise
# survive forever. Polis owns dest_root completely; replace it on every upgrade.
reset_install_root() {
  local root="$1"
  if [ -d "$root" ]; then run "rm -rf \"$root\""; fi
  run "mkdir -p \"$root\""
}

# Pre-0.5.1 Codex installers copied $polis-* wrappers to ~/.agents/skills in
# addition to ~/.codex/polis/.agents/skills. Remove only proven Polis artifacts.
cleanup_legacy_codex_skills() {
  [ "$SCOPE" = "user" ] || return 0
  local skills_root="${HOME}/.agents/skills"
  [ -d "$skills_root" ] || return 0
  local d f
  for d in "$skills_root"/polis-*; do
    [ -d "$d" ] || continue
    f="$d/SKILL.md"; [ -f "$f" ] || continue
    if grep -Eqi 'Polis|/polis:|\$polis-|\.claude/polis|Spec-driven workflow' "$f"; then
      say "codex: removing legacy duplicate skill $d"
      run "rm -rf \"$d\""
    else
      say "codex: preserving unrecognized skill $d (not proven Polis-owned)"
    fi
  done
  d="$skills_root/tdd"; f="$d/SKILL.md"
  if [ -f "$f" ] && grep -Eqi 'In Polis|Polis.*TDD|references/tdd-anti-patterns' "$f"; then
    say "codex: removing legacy global Polis tdd skill $d"
    run "rm -rf \"$d\""
  fi
}

install_claude() {
  local root; root="$(dest_root claude)"; say "claude: installing to $root (scope=$SCOPE)"
  reset_install_root "$root"
  run "bash \"$CONVERT\" --runtime claude --src \"$SRC_ROOT\" --out \"$root\""
  local settings; if [ "$SCOPE" = project ]; then settings="$(pwd)/.claude/settings.json"; else settings="$HOME/.claude/settings.json"; fi
  say "claude: plugin at $root. Optional statusline belongs in $settings."
}

install_codex() {
  local root; root="$(dest_root codex)"; say "codex: installing to $root (scope=$SCOPE)"
  cleanup_legacy_codex_skills
  reset_install_root "$root"
  run "bash \"$CONVERT\" --runtime codex --src \"$SRC_ROOT\" --out \"$root\""

  local frag_agents="$root/codex-config-fragments/codex.agents.toml"; subst_root "$frag_agents" "$root"
  local config; if [ "$SCOPE" = project ]; then config="$(pwd)/.codex/config.toml"; else config="${CODEX_HOME:-$HOME/.codex}/config.toml"; fi
  local block=""; [ -f "$frag_agents" ] && block="$(cat "$frag_agents")"$'\n'; append_block "$config" "$block"

  say "codex: installed one canonical Polis skill tree + runner declaration."
  say "codex: no Polis context hooks and no .agents/commands compatibility surface."
  say "codex: use native /statusline or /status for context telemetry."
}

install_cursor() {
  local root; root="$(dest_root cursor)"; say "cursor: installing to $root (scope=$SCOPE)"
  reset_install_root "$root"
  run "bash \"$CONVERT\" --runtime cursor --src \"$SRC_ROOT\" --out \"$root\""
  subst_root "$root/.cursor/hooks.json" "$root"
  say "cursor: hooks at $root/.cursor/hooks.json, rules at $root/.cursor/rules/."
}

uninstall_runtime() {
  local rt="$1" root; root="$(dest_root "$rt")"; say "$rt: uninstalling (scope=$SCOPE)"
  if [ "$rt" = codex ]; then
    local config; if [ "$SCOPE" = project ]; then config="$(pwd)/.codex/config.toml"; else config="${CODEX_HOME:-$HOME/.codex}/config.toml"; fi
    remove_block "$config"; cleanup_legacy_codex_skills
  fi
  [ -d "$root" ] && run "rm -rf \"$root\""
}

targets() { if [ "$RUNTIME" = all ]; then echo "claude codex cursor"; else echo "$RUNTIME"; fi; }
for rt in $(targets); do
  case "$rt" in claude|codex|cursor) ;; *) echo "install: unknown runtime: $rt" >&2; exit 2;; esac
  if [ "$UNINSTALL" -eq 1 ]; then uninstall_runtime "$rt"; else "install_$rt"; fi
done
say "done."
