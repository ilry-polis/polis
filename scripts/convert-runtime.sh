#!/usr/bin/env bash
# Polis :: convert-runtime.sh
# Convert canonical Polis sources into runtime-specific layouts.
set -euo pipefail

RUNTIME=""; SRC="."; OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --runtime) RUNTIME="${2:-}"; shift 2;;
    --src) SRC="${2:-}"; shift 2;;
    --out) OUT="${2:-}"; shift 2;;
    -h|--help) echo "convert-runtime.sh --runtime <codex|cursor|claude> --src <dir> --out <dir>"; exit 0;;
    *) echo "convert-runtime: unknown arg: $1" >&2; exit 2;;
  esac
done
[ -n "$RUNTIME" ] || { echo "convert-runtime: --runtime required" >&2; exit 2; }
[ -n "$OUT" ] || { echo "convert-runtime: --out required" >&2; exit 2; }
[ -d "$SRC" ] || { echo "convert-runtime: --src not a directory: $SRC" >&2; exit 2; }
mkdir -p "$OUT"

fm_description() {
  awk '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { exit }
    infm && /^description:/ { sub(/^description:[[:space:]]*/, ""); print; exit }
  ' "$1"
}

strip_frontmatter() {
  awk '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { infm=0; next }
    !infm { print }
  ' "$1"
}

strip_frontmatter_and_h1() {
  strip_frontmatter "$1" | awk '
    !done && /^# / { done=1; skipblank=1; next }
    skipblank && /^[[:space:]]*$/ { skipblank=0; next }
    { skipblank=0; print }
  '
}

# Main workflow entrypoints should stay tiny in Codex. The heavy methodology
# lives in one canonical internal skill, avoiding two full instruction payloads.
command_target_skill() {
  case "$1" in
    discuss) echo "brainstorming";;
    roadmap) echo "roadmapping";;
    spec) echo "writing-specs";;
    plan) echo "writing-plans";;
    exec) echo "executing-plans";;
    review) echo "code-review";;
    verify) echo "finishing-work";;
    *) echo "";;
  esac
}

convert_claude() {
  cp -R "$SRC/." "$OUT/"
  echo "[convert] claude: copied canonical layout to $OUT"
}

convert_codex() {
  mkdir -p "$OUT/.agents/skills" "$OUT/codex-config-fragments"

  # Canonical internal skills: one copy inside the plugin package.
  if [ -d "$SRC/skills" ]; then
    cp -R "$SRC/skills/." "$OUT/.agents/skills/"
  fi

  # Codex explicit commands are skills invoked with $name. Generate exactly one
  # explicit-only polis-* skill per canonical command. Do NOT emit .agents/commands.
  if [ -d "$SRC/commands" ]; then
    for f in "$SRC/commands"/*.md; do
      [ -e "$f" ] || continue
      base="$(basename "$f" .md)"
      name="polis-${base}"
      desc="$(fm_description "$f")"
      dir="$OUT/.agents/skills/$name"
      mkdir -p "$dir/agents"

      target="$(command_target_skill "$base")"
      {
        echo "---"
        echo "name: $name"
        echo "description: >-"
        echo "  Explicit Polis entrypoint: $base. Use only when the user invokes \$$name."
        echo "---"
        echo
        echo "# \$$name"
        echo
        if [ -n "$target" ]; then
          echo "This is a thin explicit entrypoint. Read and follow the canonical \`$target\` skill for this phase."
          echo "Use the user's text after \`\$$name\` as the target/arguments. Do not duplicate or restate the canonical skill before applying it."
        else
          # Support commands have no separate methodology skill; keep their
          # canonical command body here, rewriting Polis command syntax for Codex.
          strip_frontmatter_and_h1 "$f" | sed -E 's#/polis:([a-z-]+)#\$polis-\1#g'
        fi
      } > "$dir/SKILL.md"

      cat > "$dir/agents/openai.yaml" <<'YAML'
policy:
  allow_implicit_invocation: false
YAML
    done
  fi

  # Codex 0.5.1+ uses native context telemetry, so no Polis hook scripts or hook
  # fragments are emitted for Codex. Only custom agent configuration remains.
  if [ -f "$SRC/scripts/fragments/codex.agents.toml" ]; then
    cp "$SRC/scripts/fragments/codex.agents.toml" "$OUT/codex-config-fragments/"
  fi

  [ -f "$SRC/AGENTS.md" ] && cp "$SRC/AGENTS.md" "$OUT/AGENTS.md"
  [ -d "$SRC/references" ] && cp -R "$SRC/references" "$OUT/references"

  echo "[convert] codex: internal skills + explicit-only \$polis-* skills; no .agents/commands; no Polis hooks"
}

convert_cursor() {
  mkdir -p "$OUT/skills" "$OUT/.cursor/rules" "$OUT/.cursor" "$OUT/hooks"
  [ -d "$SRC/skills" ] && cp -R "$SRC/skills/." "$OUT/skills/"

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
        strip_frontmatter_and_h1 "$f"
      } > "$OUT/.cursor/rules/polis-${base}.mdc"
    done
  fi

  cp -R "$SRC/hooks/." "$OUT/hooks/"
  [ -f "$SRC/hooks/hooks-cursor.json" ] && cp "$SRC/hooks/hooks-cursor.json" "$OUT/.cursor/hooks.json"
  [ -f "$SRC/AGENTS.md" ] && cp "$SRC/AGENTS.md" "$OUT/AGENTS.md"
  [ -d "$SRC/references" ] && cp -R "$SRC/references" "$OUT/references"
  echo "[convert] cursor: skills + /polis rules + Cursor hooks"
}

case "$RUNTIME" in
  claude) convert_claude;;
  codex) convert_codex;;
  cursor) convert_cursor;;
  *) echo "convert-runtime: unknown runtime: $RUNTIME" >&2; exit 2;;
esac
