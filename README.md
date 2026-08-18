# Polis

**Spec-driven development with token-efficient agent orchestration** for Codex CLI, Claude Code, and Cursor.

Polis keeps the useful engineering discipline — discuss → spec → plan → exec → verify, behavior-focused TDD, atomic commits, risk-based review, durable state — without turning every implementation step into another agent/test/review cycle.

## Workflow

```text
DISCUSS → [ROADMAP] → SPEC → PLAN → EXEC → VERIFY
```

`ROADMAP` is only for new/large multi-phase projects.

### Planning defaults

- roughly **3–7 coherent capability tasks per feature phase**;
- tasks are vertical slices/technical boundaries, not file edits or TDD microsteps;
- one task may include related schema + types, endpoint + service + validation, or UI + state + API wiring when they form one behavior;
- if a plan wants materially more than ~7 tasks, merge artificial microtasks first or split a genuinely oversized phase.

### Execution defaults

- direct execution is allowed for trivial low-risk work when delegation costs more than the work;
- one runner normally handles one coarse task, or at most **2 closely related tasks** when local-context reuse is clearly valuable;
- maximum **2 write-capable runners** concurrently by Polis policy;
- Codex task runners cannot spawn nested agents;
- no tight `wait` / `wait_agent` / `list_agents` polling loops;
- low/medium risk gets one concise review at a useful boundary; high-risk work gets stronger independent scrutiny;
- behavior-focused TDD: observable behavior changes use RED → GREEN → REFACTOR; mechanical edits use the strongest relevant deterministic check instead of manufactured tests;
- full-suite verification belongs at meaningful integration boundaries and `$polis-verify`.

## Codex context telemetry: native, not Polis

Codex already exposes context information in its TUI/status surfaces. Its native status line supports **context remaining %**, **context used %**, **context-window size**, token counters, and usage limits when available.

Use `/statusline` once to configure the footer, or `/status` for a detailed snapshot.

**Polis installs no Codex PostToolUse context-monitor hook, no `polis-ctx-*` bridge, and no Polis WARNING/HIGH/CRITICAL thresholds on Codex.** Runtime telemetry belongs to Codex; Polis focuses on workflow.

A useful native footer can include:

```text
context-remaining
context-window-size
used-tokens
five-hour-limit
weekly-limit
```

## Codex runner

Polis installs a `polis-task-runner` configured for **GPT-5.6 Luna / medium** for narrow implementation work. Nested multi-agent tools are disabled inside that runner. The main orchestrator remains free to use a stronger model for architecture, ambiguity, or high-risk judgment.

## Install

```bash
git clone https://github.com/ilry-polis/polis.git
cd polis
bash scripts/install.sh --runtime codex --scope user
```

Runtimes: `claude | codex | cursor | all`  
Scopes: `user | project`

Reinstalling Codex is idempotent: the marker-bounded Polis block in `config.toml` is replaced. Upgrading from an older Polis version therefore removes legacy Polis context-monitor hooks automatically.

Then initialize a project:

```text
$polis-init
```

Codex commands use `$polis-*`; Claude Code/Cursor use `/polis:<cmd>`.

## Commands

| Command | Purpose |
|---|---|
| `polis-init` | Initialize state/config + detect stack |
| `polis-discuss` | Resolve design/requirements |
| `polis-roadmap` | Split a large project into vertical phases |
| `polis-spec` | Define the technical delta/contract |
| `polis-plan` | Produce 3–7 coherent implementation tasks |
| `polis-exec` | Execute with bounded orchestration |
| `polis-review` | Review against approved intent |
| `polis-verify` | Holistic verification + handoff |
| `polis-status` | Project/git status; Codex context stays native |
| `polis-next` | Recommend the next workflow action |
| `polis-health` | Validate Polis installation/state |
| `polis-config` | Adjust workflow/orchestration settings |
| `polis-pause-work` | Save durable resume state |
| `polis-resume-work` | Continue from durable state |

## Principles

1. Think before code.
2. Plan capabilities, not microsteps.
3. Test behavior, not touched files.
4. Use the fewest agent threads that preserve correctness.
5. Polling is not progress.
6. Review intensity follows risk.
7. Runtime telemetry stays runtime-native.
8. Git + STATE.md beat giant threads.
9. The user controls irreversible actions and phase transitions.

MIT licensed.
