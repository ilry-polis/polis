---
name: context-mgmt
description: Use throughout any coding session to keep the orchestrator's context window lean and protect model accuracy. Activates when context grows, when the Polis monitor reports WARNING/HIGH/CRITICAL, when deciding whether to spawn a subagent vs. work inline, and when deciding to pause. Governs the <40% orchestrator budget rule, the auto-compact reserve, and the pause/resume reflex.
---

# Context Management

Context is the scarcest resource in an agent session. As the window fills,
model accuracy degrades — not gracefully, but noticeably. Polis treats context
as a budget to be spent deliberately, not a container to be filled until it
overflows.

## The core rule: the orchestrator stays under 40%

The main session (the "orchestrator") coordinates work. It should *not* do the
heavy lifting of reading large files, running long test suites, or writing big
chunks of code directly. That work belongs in subagents with fresh context.

Why 40%? Around ~40% of the usable window, model accuracy on long, precise tasks
starts to suffer. Polis keeps the orchestrator under 40% so there's headroom for
clear thinking and clean handoffs, and the first WARNING fires exactly when that
ceiling is crossed. When you notice the orchestrator approaching that line, the
answer is almost never "push through" — it's "delegate to a subagent" or "pause
and compact."

## Usable context vs. raw window

Claude Code reserves roughly 16.5% of the window for auto-compact. Polis reports
the percentage of the *usable* remainder (~83.5%), so a Polis reading of "40%"
means 40% of the working budget, not 40% of the raw window. This is intentional:
the thresholds should track real headroom.

## Reading the monitor

Polis estimates context usage from observed tool I/O (see
references/context-budget.md for why it's an estimate, not ground truth) and
reports a threshold:

- **OK (0–40%)** — healthy orchestrator. Work normally.
- **WARNING (41–60%)** — past the ceiling. Start delegating heavy work to
  subagents and prefer short tasks. Avoid starting anything that will read a lot
  or generate a lot in the orchestrator.
- **HIGH (61–75%)** — accuracy is compromised. Finish the *current* task only,
  commit it, and prepare to pause. Do not start new tasks in the orchestrator.
- **CRITICAL (75%+)** — stop. The monitor has saved a crash breadcrumb. Run
  `/polis:pause-work`, then `/compact` (or a fresh session), then
  `/polis:resume-work`.

The estimate is deliberately conservative — it undercounts tokens it never
observes, so it errs toward warning early. Trust the direction of the signal
more than its exact number.

## The reflexes this skill installs

1. **Delegate before you fill.** Before reading a large file or running a heavy
   command in the orchestrator, ask: should a subagent do this and return only
   a summary? Usually yes. (See skills/subagent-dispatch.)
2. **Summarize, don't accumulate.** When a subagent returns, capture the
   *conclusion* in STATE.md, not the raw transcript. The orchestrator carries
   decisions, not byproducts.
3. **Commit at boundaries.** Every completed task is an atomic commit. Commits
   are the natural points to shed context safely — work is durable on disk, so
   it doesn't need to live in the window.
4. **Pause is not failure.** Pausing at HIGH/CRITICAL and resuming with fresh
   context produces better work than grinding through a degraded window. The
   STATE.md handoff is designed so resume loses nothing important.

## When the runtime can't measure context

On runtimes that don't expose usage to hooks (all three supported runtimes, to
varying degrees), the estimate is your only gauge. Supplement it with judgment:
if you've read several large files, run a big test suite, or had a long
back-and-forth, assume you're higher than the bar reads and lean toward
delegating or pausing.
