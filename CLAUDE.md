# Polis — Claude Code Instructions

Polis is active in this project. It enforces a spec-driven workflow with isolated
subagents and active context management. Follow it.

## The workflow

Drive every build through these phases, each gated by the user's approval:

**discuss → spec → plan → exec → verify**

- **Don't jump to code.** When asked to build something, start a discussion
  (`/polis:discuss`) to agree the design, then write a spec, then a plan, then
  execute. Code is the last step.
- **New project?** After discuss, run `/polis:roadmap` to cut the whole app into
  phases (vertical-slice capabilities, granularity coarse/standard/fine). Then run
  spec → plan → exec → verify on each phase, one at a time.
- **Each phase needs approval.** Propose; let the user decide before advancing.

## Context discipline

- Keep this orchestrator session **under 40%** of the usable window.
- Push heavy work — large reads, test runs, code generation — into **subagents**
  with fresh context. Pull back only the outcome, never the full transcript.
- Watch the Polis monitor. At **WARNING (40%+)** start delegating and prefer
  short tasks; at **HIGH (65%+)** finish and commit the current task only; at
  **CRITICAL (80%+)** run `/polis:pause-work`, then `/compact`, then
  `/polis:resume-work`.
- The percentage is the real context usage (Claude Code exposes it); thresholds
  match what `/context` shows.

## Execution rules

- **TDD is mandatory.** RED → GREEN → REFACTOR. Test first; if production code
  gets written before its test, delete it and restart.
- **Atomic commits.** One task, one commit, message `[polis] T<n>: <what>`.
- **Two-phase review** after each task: compliance (does it match the spec?) then
  quality (conventions, smells). Fix failures before advancing.
- **When something breaks**, debug systematically — root-cause before any fix,
  one hypothesis at a time, fix the source not the symptom. 3+ failed fixes means
  stop and question the design.
- **Never claim done without evidence** — run the command, read the output. A
  subagent's "tests pass" is a claim, not proof; verify it yourself.

## Commands

`/polis:init` `/polis:discuss` `/polis:roadmap` `/polis:spec` `/polis:plan`
`/polis:exec` `/polis:review` `/polis:verify` `/polis:status` `/polis:next`
`/polis:health` `/polis:config` `/polis:pause-work` `/polis:resume-work`

## State

`.claude/polis/STATE.md` is the source of truth for project phase and progress;
`specs/` and `plans/` hold versioned intent. Between git and STATE.md, nothing is
lost to a context reset.

## Boundaries

Polis proposes; the human decides irreversible actions. Polis does not
unilaterally merge, push to protected branches, open/merge PRs, change repo
permissions, or delete work. Surface the action for the user to approve.

For the full mental model, see the `using-plugin` skill.
