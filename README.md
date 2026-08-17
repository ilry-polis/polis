# Polis

**A multi-runtime plugin for coding agents.** Polis combines spec-driven
development, context engineering, TDD, atomic commits, and **token-efficient
agent orchestration** for Claude Code, Codex CLI, and Cursor.

Zero external dependencies. MIT licensed.

## Why Polis exists

Coding agents commonly fail by jumping to code too early, letting context rot,
or over-orchestrating work into expensive agent trees. Polis prevents all three:

- gated **discuss → spec → plan → exec → verify** workflow;
- coherent plans instead of microtask explosions;
- TDD + atomic commits for reversible implementation;
- bounded subagents when isolation/parallelism is actually useful;
- risk-based review and final holistic verification;
- durable STATE.md + pause/resume instead of replaying history.

## Workflow

```text
DISCUSS → SPEC → PLAN → EXEC → VERIFY
                   │       │
                   │       ├─ direct trivial/low-risk work when cheaper
                   │       └─ bounded runner batches when isolation helps
                   │
                   └─ coherent tasks, usually ~5–12 per feature phase
```

For new/large projects, `/polis:roadmap` sits between discuss and spec and splits
the product into phases.

### Token-efficient execution defaults

- **1–3 related tasks per runner batch**; each task still has its own TDD cycle
  and atomic commit.
- **max 2 concurrent write-capable runners** by default.
- **no nested subagents** from a Polis task runner.
- **bounded waiting:** one wait for a wave, useful coordinator work, then at most
  one later wait — never tight polling loops.
- **risk-based review:** one combined batch review for low/medium risk; stronger
  independent scrutiny for auth, permissions, billing, security, destructive
  data/migrations, and similar high-risk work.
- targeted tests during execution; full-suite verification at meaningful
  integration boundaries and `/polis:verify`.

These defaults exist because every subagent performs its own model/tool work.
Subagents are a deliberate trade for cleaner context and real parallel speedup,
not the default unit of every plan item.

## Context discipline

Context thresholds remain health signals:

```text
WARNING 40%+  → reduce broad reads/output; finish current batch
HIGH    65%+  → checkpoint current work only
CRITICAL80%+  → pause-work → compact/restart → resume-work
```

A threshold crossing does **not** automatically mean "spawn another agent".
Shrink inputs first: targeted file anchors/searches, concise command output, git,
and STATE.md.

## Install

Clone/download the repository, then from the Polis folder:

```bash
bash scripts/install.sh --runtime codex --scope user
# runtime: claude | codex | cursor | all
# scope:   user | project
```

Claude Code marketplace:

```text
/plugin marketplace add ilry-polis/polis
/plugin install polis@polis-marketplace
```

Then initialize the target project:

```text
/polis:init
```

Codex invocation uses `$`, for example `$polis-init`, `$polis-plan`,
`$polis-exec`. Claude Code/Cursor use `/polis:<cmd>`.

## Commands

| Command | Purpose |
|---|---|
| `/polis:init` | Initialize state/config and detect stack |
| `/polis:discuss` | Resolve requirements/design before code |
| `/polis:roadmap` | Split a new/large project into phases |
| `/polis:spec` | Write executable technical specification |
| `/polis:plan` | Build coherent tasks + execution batches |
| `/polis:exec` | Execute with bounded, token-efficient orchestration |
| `/polis:review` | Review against approved spec/plan |
| `/polis:verify` | Final full verification + handoff |
| `/polis:status` | Show phase/progress/context state |
| `/polis:next` | Recommend next workflow action |
| `/polis:health` | Check Polis integrity |
| `/polis:config` | Workflow/context/orchestration preferences |
| `/polis:pause-work` | Durable checkpoint before context reset |
| `/polis:resume-work` | Resume from durable state |

## Default project orchestration config

`/polis:init` merge-fills:

```json
{
  "orchestration": {
    "maxTasksPerBatch": 3,
    "maxConcurrentAgents": 2,
    "maxWaitCyclesPerWave": 2,
    "reviewMode": "risk-based",
    "allowDirectLowRisk": true
  }
}
```

For Codex, Polis also installs a custom `polis-task-runner` configured for
`gpt-5.6-luna` at medium reasoning, with runtime concurrency capped at two
spawned threads. The main orchestrator remains free to use a stronger model for
architecture, ambiguity, or high-risk judgment.

## Execution example

```text
You: $polis-plan rate-limiter
Polis: T1..T7 coherent tasks grouped into B1..B3, each with tests/risk/deps

You: $polis-exec rate-limiter
Polis: B1 → one runner handles T1,T2 sequentially → two atomic commits
       B2/B3 run sequentially or up to two-way parallel only if independent
       no nested agents; bounded waits; one batch review

You: $polis-verify rate-limiter
Polis: full suite/lint/acceptance criteria → merge-ready evidence
```

## Organization

```text
polis/
├── .claude-plugin/
├── .codex-plugin/
├── .cursor-plugin/
├── skills/
├── hooks/
├── commands/
├── references/
├── scripts/
├── CLAUDE.md / AGENTS.md
└── package.json
```

Canonical workflow content is authored once and converted per runtime by
`scripts/convert-runtime.sh`; `scripts/install.sh` wires hooks/config safely with
Polis markers.

## Principles

1. Think before code.
2. Keep context focused; don't replay history.
3. Use the fewest coherent tasks/agent threads that preserve correctness.
4. TDD is mandatory.
5. One task = one reversible commit, even inside a batch.
6. Review intensity follows risk.
7. Polling is not progress.
8. Durable state beats giant threads.
9. The user controls irreversible actions and phase transitions.

## License

MIT. See `LICENSE`.
