# Publishing Polis

How to distribute Polis on each runtime. Procedures reflect the state of each
ecosystem as of mid-2026; verify against current docs before a public release,
since plugin tooling moves fast.

Polis is authored once in the Claude Code format and converted per runtime by
`scripts/install.sh`. For end users who just want to *use* Polis, the installer
is the path — this document is for *publishing* it for others to discover.

---

## Claude Code

Claude Code distributes plugins through **marketplaces** — a git repo containing
a `.claude-plugin/marketplace.json` catalog that points at one or more plugins.

**Repo layout (already in place):**

```
polis/
├── .claude-plugin/
│   ├── plugin.json        # the plugin manifest
│   └── marketplace.json   # the marketplace catalog listing polis
├── commands/  skills/  hooks/  references/   # components at root
└── ...
```

**Publish:**

1. Push this repo to GitHub (public, or private for a team).
2. Set the `owner` in `.claude-plugin/marketplace.json` to your real name/handle.
3. Validate locally before sharing:
   ```
   claude plugin validate .
   ```
   (Unrecognized fields are warnings, not errors; wrong-typed fields fail.)
4. Users then add and install:
   ```
   /plugin marketplace add ilry-polis/polis
   /plugin install polis@polis-marketplace
   ```

**Notes:**
- Skills are namespaced once installed (`/polis:discuss`, not `/discuss`).
- The statusline isn't auto-wired by the plugin — users add the `statusLine`
  line to their `settings.json` (the installer prints the exact line). This is
  intentional: `settings.json` is the user's.
- Relative `source` paths in `marketplace.json` resolve only for git-based adds.
  If you ever distribute the catalog by direct URL, use a `github`/git source
  instead of `./`.

---

## Codex CLI

Codex gained an official plugin system (March 2026): a `.codex-plugin/plugin.json`
manifest, skills under `.agents/skills/`, and Git-backed marketplaces.

**What ships for Codex** (produced by `convert-runtime.sh --runtime codex`):
- `.agents/skills/<name>/SKILL.md` — discovered automatically.
- `AGENTS.md` — project/user instructions.
- TOML fragments for `config.toml` — the context-monitor hook and the
  `polis-task-runner` subagent role — applied by the installer.

**Publish:**

1. Push to GitHub with the `.codex-plugin/plugin.json` manifest at the repo root
   (or in the plugin subdirectory).
2. Distribute via a **Git-backed marketplace** — self-serve publishing to the
   official Codex Plugin Directory was still "coming soon" as of May 2026, so
   the reliable path is a git marketplace or a direct repo path install.
3. Standalone skills can also be installed directly without a marketplace, since
   Codex auto-discovers `.agents/skills/`.

**Notes:**
- Codex runs **command hooks only** — prompt/agent hook handlers are parsed but
  skipped. The context monitor is a command hook; the in-context nudge comes via
  `AGENTS.md` + the `context-mgmt` skill.
- Codex spawns subagents **only when explicitly asked**, so `/polis:exec`
  dispatches to the `polis-task-runner` role per task rather than implicitly.
- There's no version pinning for marketplace plugins; teams wanting stability
  should vendor a pinned copy via a repo-scoped local marketplace.

---

## Cursor

Cursor has no formal "plugin" package; it consumes project/user files directly:
`.cursor/hooks.json`, `.cursor/rules/*.mdc`, and `AGENTS.md`.

**What ships for Cursor** (produced by `convert-runtime.sh --runtime cursor`):
- `skills/<name>/SKILL.md`
- `.cursor/rules/polis-<name>.mdc` — one rule per command, invoked `/polis:<name>`.
- `.cursor/hooks.json` — the context-monitor wiring.
- `AGENTS.md` — instructions.

**Publish / share:**

1. Distribution is by repository: share the repo, and have users either run the
   installer or copy the generated `.cursor/` directory into their project.
2. The hook commands reference `$CURSOR_PLUGIN_ROOT`; users export it to the
   install path, or place `.cursor/` at the project root so paths resolve.

**Notes:**
- Cursor runs command hooks; events are camelCase (`beforeSubmitPrompt`,
  `afterFileEdit`, `stop`).
- Rules with `alwaysApply: false` activate by description/context, matching the
  "skills fire automatically" principle.

---

## Before any public release

- [ ] Set the real copyright holder in `LICENSE` and `owner` in the marketplace.
- [ ] Run `claude plugin validate .` and fix anything that fails (not just warns).
- [ ] Test the installer end-to-end per runtime (`--dry-run`, then real, then
      `--uninstall`) on a throwaway project.
- [ ] Confirm no secrets or machine-specific paths are committed (the install
      paths are resolved at install time, not baked into the repo).
- [ ] Tag a version and keep `version` fields in sync across `package.json`,
      `plugin.json` files, and `marketplace.json`.
