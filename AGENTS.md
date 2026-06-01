# Polis — Agent Instructions (Codex / Cursor)

Polis is active in this project. It enforces a spec-driven workflow with isolated
subagents and active context management. This file is read by Codex CLI and by
Cursor as the project instruction source. Follow it.

> Runtime note: Polis is authored once in the Claude Code format and converted
> per runtime by `scripts/install.sh`. The workflow and principles below are
> identical across runtimes; only the invocation syntax and hook plumbing differ.

## The workflow

Drive every build through these phases, each gated by the user's approval:

**discuss → spec → plan → exec → verify**

- **Don't jump to code.** Agree the design first, then spec, then plan, then
  execute. Code is the last step.
- **New project?** After discuss, run roadmap to cut the app into phases
  (vertical-slice capabilities; granularity coarse/standard/fine), then run
  spec → plan → exec → verify per phase, one at a time.
- **Each phase needs approval.** Propose; let the user decide before advancing.

## Invocation per runtime

- **Codex CLI:** commands are invoked with the `$` prefix, e.g. `$polis-discuss`,
  `$polis-spec`, `$polis-exec`. Skills live under `.agents/skills/` and load by
  context. Subagents use Codex's `[agents]` configuration; note Codex only spawns
  subagents when explicitly asked.
- **Cursor:** commands are invoked as `/polis:<cmd>`. Rules live under
  `.cursor/rules/`. Hooks (`beforeSubmitPrompt`, `afterFileEdit`, `stop`) drive
  the context monitor.

## Context discipline

- Keep the main session **under 40%** of the usable window.
- Push heavy work into **subagents** with fresh context; pull back only the
  outcome, not the transcript.
- At **WARNING (40%+)** start delegating and prefer short tasks; at **HIGH
  (65%+)** finish and commit the current task only; at **CRITICAL (80%+)**
  pause, compact/restart, resume.
- On Claude Code the percentage is the real context usage (matches `/context`).
  On runtimes that don't expose it, the monitor stays silent rather than guessing.

> Codex/Cursor hook note: both runtimes run **command hooks** only. Codex parses
> but skips prompt/agent hook handlers. So the context monitor runs as a command
> hook and surfaces signals; the in-context nudge comes from this file and the
> context-mgmt skill, which is the portable way to deliver it.

## Execution rules

- **TDD is mandatory.** RED → GREEN → REFACTOR. Test first; if production code is
  written before its test, delete it and restart.
- **Atomic commits.** One task, one commit, `[polis] T<n>: <what>`.
- **Two-phase review** after each task: compliance, then quality. Fix before
  advancing.
- **When something breaks**, debug systematically — root-cause before any fix, one
  hypothesis at a time, fix the source. 3+ failed fixes ⇒ stop, question the design.
- **Never claim done without evidence** — run it, read the output. A subagent's
  self-report is a claim, not proof.

## State

`.claude/polis/STATE.md` (or the runtime-equivalent path) is the source of truth
for phase and progress; `specs/` and `plans/` hold versioned intent. Between git
and STATE.md, nothing is lost to a context reset.

## Boundaries

Polis proposes; the human decides irreversible actions. No unilateral merges,
pushes to protected branches, PR open/merge, permission changes, or deletions.

For the full mental model, see the `using-plugin` skill.
