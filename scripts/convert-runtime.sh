#!/usr/bin/env bash
# ============================================================================
# Polis :: convert-runtime.sh
# ----------------------------------------------------------------------------
# Converts Polis from its CANONICAL form (Claude Code: markdown + YAML
# frontmatter + hooks.json) into the layout a target runtime expects.
#
# Canonical source is authored once. This script performs the per-runtime
# transformations:
#   - command slug -> invocation prefix  (/polis:cmd | $polis-cmd)
#   - hook events  -> per-runtime event names / schema
#   - paths        -> per-runtime directories
#   - placeholders -> per-runtime plugin-root variable
#
# It is invoked by install.sh, but is runnable standalone for inspection:
#   bash scripts/convert-runtime.sh --runtime codex  --src . --out /tmp/out
#   bash scripts/convert-runtime.sh --runtime cursor --src . --out /tmp/out
#
# It NEVER writes outside --out. It does not touch the user's real config; that
# wiring (appending TOML, registering hooks) is install.sh's job.
# ============================================================================

set -euo pipefail

RUNTIME=""
SRC="."
OUT=""

usage() {
  cat <<'USAGE'
convert-runtime.sh --runtime <codex|cursor|claude> --src <dir> --out <dir>

  --runtime  target runtime (claude is a passthrough copy)
  --src      canonical Polis source directory (default: .)
  --out      output directory to write the converted layout into
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --runtime) RUNTIME="${2:-}"; shift 2;;
    --src) SRC="${2:-}"; shift 2;;
    --out) OUT="${2:-}"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "convert-runtime: unknown arg: $1" >&2; usage; exit 2;;
  esac
done

[ -n "$RUNTIME" ] || { echo "convert-runtime: --runtime required" >&2; exit 2; }
[ -n "$OUT" ] || { echo "convert-runtime: --out required" >&2; exit 2; }
[ -d "$SRC" ] || { echo "convert-runtime: --src not a directory: $SRC" >&2; exit 2; }

mkdir -p "$OUT"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Extract the YAML frontmatter description from a command markdown file.
fm_description() {
  awk '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { exit }
    infm && /^description:/ {
      sub(/^description:[[:space:]]*/, "")
      print
      exit
    }
  ' "$1"
}

# Strip the YAML frontmatter, returning just the body of a markdown file.
strip_frontmatter() {
  awk '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { infm=0; next }
    !infm { print }
  ' "$1"
}

# Strip frontmatter AND the first H1 heading (and the blank line after it), so a
# converted file can supply its own retitled heading without duplicating the
# original. Used for command-body inclusion in Codex/Cursor outputs.
strip_frontmatter_and_h1() {
  strip_frontmatter "$1" | awk '
    !done && /^# / { done=1; skipblank=1; next }
    skipblank && /^[[:space:]]*$/ { skipblank=0; next }
    { skipblank=0; print }
  '
}

# ---------------------------------------------------------------------------
# CLAUDE: passthrough. The canonical form IS the Claude Code form.
# ---------------------------------------------------------------------------
convert_claude() {
  cp -R "$SRC/." "$OUT/"
  echo "[convert] claude: copied canonical layout to $OUT"
}

# ---------------------------------------------------------------------------
# CODEX:
#   - skills        -> .agents/skills/<name>/SKILL.md  (copied as-is)
#   - commands      -> .agents/commands/polis-<name>.md, invoked as $polis-<name>
#   - hooks/agents  -> TOML fragments (emitted to OUT/codex-config-fragments/)
#   - instructions  -> AGENTS.md (copied)
# ---------------------------------------------------------------------------
convert_codex() {
  mkdir -p "$OUT/.agents/skills" "$OUT/.agents/commands" "$OUT/codex-config-fragments" "$OUT/hooks"

  # Skills: same SKILL.md format, different directory.
  if [ -d "$SRC/skills" ]; then
    cp -R "$SRC/skills/." "$OUT/.agents/skills/"
  fi

  # Commands: rewrite the invocation hint to the $ prefix and rename slug.
  if [ -d "$SRC/commands" ]; then
    for f in "$SRC/commands"/*.md; do
      [ -e "$f" ] || continue
      base="$(basename "$f" .md)"
      desc="$(fm_description "$f")"
      {
        echo "# \$polis-${base}"
        echo
        echo "> ${desc}"
        echo
        echo "> Codex invocation: \`\$polis-${base}\`"
        echo
        strip_frontmatter_and_h1 "$f"
      } > "$OUT/.agents/commands/polis-${base}.md"
    done
  fi

  # Hooks: ship the scripts and the TOML fragments (root placeholder intact;
  # install.sh substitutes {POLIS_ROOT} when it appends to the real config).
  cp -R "$SRC/hooks/." "$OUT/hooks/"
  if [ -f "$SRC/scripts/fragments/codex.hooks.toml" ]; then
    cp "$SRC/scripts/fragments/codex.hooks.toml" "$OUT/codex-config-fragments/"
  fi
  if [ -f "$SRC/scripts/fragments/codex.agents.toml" ]; then
    cp "$SRC/scripts/fragments/codex.agents.toml" "$OUT/codex-config-fragments/"
  fi

  # Instructions.
  [ -f "$SRC/AGENTS.md" ] && cp "$SRC/AGENTS.md" "$OUT/AGENTS.md"
  [ -f "$SRC/references" ] || true
  [ -d "$SRC/references" ] && cp -R "$SRC/references" "$OUT/references"

  echo "[convert] codex: skills -> .agents/skills, commands -> \$polis-<name>, hooks + TOML fragments emitted"
}

# ---------------------------------------------------------------------------
# CURSOR:
#   - skills        -> skills/<name>/SKILL.md  (copied as-is)
#   - commands      -> .cursor/rules/polis-<name>.mdc, invoked as /polis:<name>
#   - hooks         -> .cursor/hooks.json (from canonical hooks-cursor.json)
#   - instructions  -> AGENTS.md (copied)
# ---------------------------------------------------------------------------
convert_cursor() {
  mkdir -p "$OUT/skills" "$OUT/.cursor/rules" "$OUT/.cursor" "$OUT/hooks"

  if [ -d "$SRC/skills" ]; then
    cp -R "$SRC/skills/." "$OUT/skills/"
  fi

  # Commands -> .mdc rules. .mdc files use YAML frontmatter too; we emit a
  # rule that documents the /polis:<name> command and carries its body.
  if [ -d "$SRC/commands" ]; then
    for f in "$SRC/commands"/*.md; do
      [ -e "$f" ] || continue
      base="$(basename "$f" .md)"
      desc="$(fm_description "$f")"
      {
        echo "---"
        echo "description: ${desc}"
        echo "alwaysApply: false"
        echo "---"
        echo
        echo "# /polis:${base}"
        echo
        echo "> Cursor invocation: \`/polis:${base}\`"
        echo
        strip_frontmatter_and_h1 "$f"
      } > "$OUT/.cursor/rules/polis-${base}.mdc"
    done
  fi

  # Hooks: the canonical Cursor mapping becomes .cursor/hooks.json.
  cp -R "$SRC/hooks/." "$OUT/hooks/"
  if [ -f "$SRC/hooks/hooks-cursor.json" ]; then
    cp "$SRC/hooks/hooks-cursor.json" "$OUT/.cursor/hooks.json"
  fi

  [ -f "$SRC/AGENTS.md" ] && cp "$SRC/AGENTS.md" "$OUT/AGENTS.md"
  [ -d "$SRC/references" ] && cp -R "$SRC/references" "$OUT/references"

  echo "[convert] cursor: skills -> skills/, commands -> .cursor/rules/*.mdc (/polis:<name>), hooks -> .cursor/hooks.json"
}

case "$RUNTIME" in
  claude) convert_claude;;
  codex) convert_codex;;
  cursor) convert_cursor;;
  *) echo "convert-runtime: unknown runtime: $RUNTIME" >&2; exit 2;;
esac
