# Polis

**A multi-runtime plugin for coding agents.** Polis fuses two disciplines into
one workflow: *context engineering* (keep the agent's working memory lean and
accurate) and *spec-driven development with isolated subagents* (think before
building, build in small verified steps). It runs natively on **Claude Code**,
**Codex CLI**, and **Cursor**.

Zero external dependencies. Markdown, JSON, vanilla JS, and Bash only. MIT
licensed.

---

## Why Polis exists

Coding agents fail in two predictable ways. They **jump to code** before anyone
agreed what to build, and they **fill their context window** until accuracy
quietly collapses. Polis is built to prevent both.

- A gated workflow — **discuss → spec → plan → exec → verify** — means code is
  the last step, not the first.
- Heavy work runs in **fresh-context subagents**, so the main session (the
  orchestrator) stays lean and sharp.
- **TDD** and **atomic commits** keep every step verifiable and reversible.
- **Pause/resume** state means a full context window is never a crisis — you
  save, compact, and pick up exactly where you left off.

The name is deliberate: a *polis* is a well-ordered city. The point isn't
ceremony, it's that order in the small steps is what lets you move fast without
making a mess.

---

## The workflow

```
[describe what you want]
        │
        ▼
   ┌─────────┐
   │ DISCUSS │  Socratic Q&A, alternatives, gray areas → approved design
   └────┬────┘
        ▼
   ┌─────────┐
   │  SPEC   │  Executable spec: interfaces, edge cases, acceptance criteria
   └────┬────┘
        ▼
   ┌─────────┐
   │  PLAN   │  Atomic 2–5 min tasks, each with a test written first
   └────┬────┘
        ▼
   ┌─────────┐      ┌──────────────┐
   │  EXEC   │─────▶│  SUBAGENTS   │  fresh context per task, TDD,
   └────┬────┘      │  + 2-phase    │  atomic commits
        │           │   review      │
        ▼           └──────────────┘
   ┌─────────┐
   │ VERIFY  │  Full suite, lint, holistic spec compliance → merge-ready
   └─────────┘
```

Each phase needs your approval to advance. Polis proposes; you decide.

Meanwhile, the context monitor watches the window:

```
WARNING (40%+)  → start delegating, prefer short tasks
HIGH    (65%+)  → finish & commit current task only
CRITICAL(80%+)  → pause-work → compact → resume-work (skull)
```

> **How the monitor reads context:** Claude Code exposes the live context state
> to the statusline, so Polis reads the **real** usage — no estimation. It judges
> thresholds on the figure that matches `/context`, and the bar leans a little
> early (a normalized value) as an action nudge. CRITICAL means CRITICAL.

---

## Get Polis

If you use **Claude Code**, you can skip downloading entirely — the marketplace
path below fetches everything for you. For Codex, Cursor, or if you just want the
files, get them one of these ways:

**Clone with git** (recommended if you have git):

```bash
git clone https://github.com/ilry-polis/polis.git
cd polis
```

**Download the ZIP** (no git needed): on the GitHub repo page, click the green
**Code** button → **Download ZIP**, then unzip it and open the folder:

```bash
unzip polis-main.zip
cd polis-main
```

Either way you end up in the Polis folder, ready to run the installer.

---

## Install

### Path A — Claude Code marketplace (Claude Code only)

```
/plugin marketplace add ilry-polis/polis
/plugin install polis@polis-marketplace
```

One line, no manual download. This is the simplest path if you use Claude Code.

### Path B — the installer (any runtime)

From inside the Polis folder (see **Get Polis** above), run the installer for
your runtime:

```bash
bash scripts/install.sh --runtime claude --scope project   # claude | codex | cursor | all
```

Flags:
- `--runtime claude | codex | cursor | all`
- `--scope project` (this repo) `| user` (your global runtime config)
- `--uninstall` — removes Polis cleanly (marker-bounded; never touches your work)
- `--dry-run` — show what would happen, write nothing

Codex and Cursor don't have a one-line marketplace path equivalent to Path A —
use Path B for those.

### Then initialize

Once installed, set Polis up in your project:

```
/polis:init
```

---

## Commands

| Command | What it does |
|---|---|
| `/polis:init` | Set up Polis in the project; detect the stack |
| `/polis:discuss` | Socratic brainstorming before any code |
| `/polis:roadmap` | Cut a new project into phases (new/large projects) |
| `/polis:spec` | Write the executable technical spec |
| `/polis:plan` | Break the spec into atomic, testable tasks |
| `/polis:exec` | Execute the plan via isolated subagents |
| `/polis:review` | Code review against the spec (severity-classified) |
| `/polis:verify` | Final verification + prepare handoff |
| `/polis:status` | Phase, progress, context estimate at a glance |
| `/polis:next` | Detect the single best next action |
| `/polis:health` | Check Polis integrity |
| `/polis:config` | Workflow toggles and context tunables |
| `/polis:pause-work` | Save full state + commit, ready for compact |
| `/polis:resume-work` | Restore context and resume without loss |

Invocation differs by runtime: `/polis:<cmd>` on Claude Code and Cursor,
`$polis-<cmd>` on Codex.

---

## A short walkthrough

```
You:  /polis:discuss  I want a rate limiter for our API
Polis: (asks about scope, algorithm, per-key vs global, storage, failure mode;
       proposes token-bucket with Redis, notes the trade-offs; you converge)
       → saves specs/design-rate-limiter.md

You:  /polis:spec rate-limiter
Polis: (writes interfaces, the Redis key schema, edge cases — clock skew, Redis
       down — and measurable acceptance criteria; you approve)
       → specs/spec-rate-limiter-v1.md

You:  /polis:plan rate-limiter
Polis: (reads the codebase, emits T1..T7: each a 2–5 min task with a test first,
       exact file paths, dependencies; verifies every acceptance criterion maps
       to a task; you approve)
       → plans/plan-rate-limiter-v1.md

You:  /polis:exec rate-limiter
Polis: (dispatches T1 to a fresh subagent → TDD → commit → 2-phase review →
       records outcome; repeats; runs independent tasks in parallel waves; keeps
       the orchestrator under 40%)

You:  /polis:verify rate-limiter
Polis: (full suite green, lint clean, every acceptance criterion satisfied,
       drafts the PR summary; leaves the merge for you)
```

---

## How it's organized

```
polis/
├── .claude-plugin/        # Claude Code manifest + marketplace catalog
├── .codex-plugin/         # Codex plugin manifest
├── .cursor-plugin/        # Cursor descriptor (metadata for the installer)
├── skills/                # The methodology — 14 skills, fire by context
├── hooks/                 # statusline + context monitor + bootstrap + wiring
├── commands/              # 14 slash commands (thin entry points to skills)
├── references/            # Context budget, anti-patterns, subagent guidelines
├── scripts/               # install.sh, convert-runtime.sh, TOML fragments
├── CLAUDE.md / AGENTS.md   # Per-runtime bootstrap instructions
├── PUBLISHING.md           # How to distribute on each runtime
└── package.json            # Metadata only — zero dependencies
```

**Canonical source, multiple targets.** Everything is authored once in the
Claude Code format (markdown + YAML frontmatter). `scripts/install.sh` runs
`scripts/convert-runtime.sh` to emit the right layout per runtime — command
prefixes, hook event names, directory paths, and config plumbing all adapt
automatically.

**State that survives anything.** `.claude/polis/STATE.md` holds the project's
phase, progress, and a resume breadcrumb. `specs/` and `plans/` hold versioned
intent. Between git and STATE.md, no work is lost to a context reset.

---

## Runtime reality

Polis adapts to what each runtime actually supports, not an idealized version:

- **Claude Code** — full surface: `.claude-plugin/plugin.json`, skills, commands,
  `hooks.json` lifecycle hooks, and a statusline (wired in `settings.json`).
- **Codex CLI** — official plugin system; skills under `.agents/skills/`,
  `AGENTS.md`, subagent roles and hooks in `config.toml`. **Command hooks only**
  (prompt/agent handlers are skipped), and subagents spawn only when asked.
- **Cursor** — no formal plugin package; `.cursor/hooks.json` (camelCase events),
  `.cursor/rules/*.mdc`, and `AGENTS.md`.

The context monitor is a *sensor* (it measures and records); the in-context
guidance is delivered by the session bootstrap + the `context-mgmt` skill (the
*voice*). This split exists because most runtimes' tool-completion hooks can
observe but can't inject into the model's prompt.

---

## Principles

1. Don't jump to code — discuss → spec → plan first.
2. Context is sacred — orchestrator under 40%, heavy work in subagents.
3. Every task is atomic — one commit, reversible.
4. TDD is not optional — RED → GREEN → REFACTOR.
5. State survives sessions — pause and resume without loss.
6. Language agnostic — auto-detects the stack; nothing hardcoded.
7. Multi-runtime for real — one source, three targets.
8. Skills fire automatically — the agent doesn't need to be told to use them.
9. The user is in control — each phase needs approval; Polis proposes, you decide.

---

## License

MIT. See [LICENSE](./LICENSE). To publish, see [PUBLISHING.md](./PUBLISHING.md).
