---
name: using-plugin
description: Use to understand how the whole Polis system fits together — the workflow phases, when each skill and command applies, how context management and subagents interact, and the principles that govern everything. The orienting meta-skill; consult it when unsure which part of Polis applies or how the pieces connect.
---

# Using Polis

Polis is a workflow, not a toolbox. The individual skills and commands only make
sense as parts of one loop: think before building, build in small verified
steps, and keep the context window lean the whole way. This skill is the map.

## The one-sentence model

Drive every build through **discuss → spec → plan → exec → verify**, keeping the
orchestrator under 40% by pushing heavy work into fresh-context subagents, with
TDD and atomic commits throughout, and the user approving each phase.

## The phases, and what runs each

| Phase | Command | Skill | Produces |
|---|---|---|---|
| Discuss | `/polis:discuss` | brainstorming | `specs/design-<f>.md` |
| Spec | `/polis:spec` | writing-specs | `specs/spec-<f>-v<n>.md` |
| Plan | `/polis:plan` | writing-plans | `plans/plan-<f>-v<n>.md` |
| Exec | `/polis:exec` | executing-plans + subagent-dispatch + tdd | atomic commits |
| Verify | `/polis:verify` | finishing-work + code-review | merge-ready feature |

Cross-cutting, always on: **context-mgmt** (watches the window), **project-detect**
(knows the stack), **code-review** (the review step inside exec and verify).

## When each piece fires

Most skills activate by context, not by command — that's the design (principle:
skills fire automatically). You don't have to be told to manage context or detect
the stack; the descriptions trigger them. The commands are explicit entry points
for when the user wants to drive a specific phase.

- User describes something to build → **brainstorming** wakes up. Don't code.
- Design agreed → **writing-specs**.
- Spec agreed → **writing-plans**.
- Executing → **executing-plans** dispatches to subagents (**subagent-dispatch**),
  each doing **tdd**; **code-review** gates each task.
- Finishing → **finishing-work** verifies and prepares handoff.
- Throughout → **context-mgmt** reads the monitor; at WARNING/HIGH/CRITICAL it
  changes behavior (short tasks → finish-and-commit → pause).

## Support commands

`/polis:init` (set up), `/polis:status` (where am I), `/polis:next` (what next),
`/polis:health` (is Polis intact), `/polis:config` (toggles),
`/polis:pause-work` & `/polis:resume-work` (stop and restart without loss).

## The state that ties it together

`.claude/polis/STATE.md` is the single source of truth for where the project is —
phase, progress, decisions, and the `Stopped At` breadcrumb for pause/resume.
`specs/` and `plans/` hold versioned intent. `history/` holds finished-milestone
summaries. `config.json` holds preferences. Git holds the code. Between git and
STATE.md, no work is ever lost to a context reset.

## The principles, compressed

1. Don't jump to code — discuss/spec/plan first.
2. Context is sacred — orchestrator under 40%, heavy work in subagents.
3. Every task is atomic — one commit, reversible.
4. TDD is not optional — RED → GREEN → REFACTOR.
5. State survives sessions — pause and resume without loss.
6. The user is in control — each phase needs approval; Polis proposes, the human
   decides.

## How to think about it

When in doubt, ask two questions: *which phase am I in?* and *is the orchestrator
getting heavy?* The first tells you which skill applies; the second tells you
whether to delegate or pause. Almost every Polis decision reduces to those two.
