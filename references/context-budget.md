# Context Budget — Rules & Rationale

This reference defines how Polis accounts for context, why the numbers are what
they are, and the honest limits of what Polis can actually measure.

## What Polis measures

**Claude Code exposes the real context state.** The statusline payload includes
`context_window.remaining_percentage` and `total_tokens`. Polis reads that
directly — no tokenization, no transcript scanning, no I/O accumulation. The
number is ground truth from the runtime, not a guess.

(On runtimes that don't expose this — e.g. some Cursor/Codex hook contexts — the
monitor simply has nothing to judge that turn and stays silent rather than
estimating. Polis prefers no signal to a fabricated one.)

## Raw vs normalized — the two numbers

Polis derives two percentages from the real `remaining_percentage`:

- **Raw used%** = `100 − remaining`. This matches what Claude Code's native
  `/context` command shows. The **monitor** judges its thresholds on this, so
  Polis's CRITICAL fires in step with what you see in `/context`.
- **Normalized used%** = the raw value rescaled against the *usable* window
  (everything before the auto-compact buffer kicks in). The **statusline bar**
  shows this. It runs ~13 points ahead of raw on purpose: the bar is an action
  prompt ("delegate / pause soon"), so it leans early.

Why the split: a normalized-only meter over-warns relative to `/context` (a known
discrepancy), which erodes trust in the signal. Showing the action-oriented
number on the bar while judging thresholds on the native-matching number gives
both an early nudge and an honest CRITICAL.

## The numbers

| Quantity | Value | Why |
|---|---|---|
| Auto-compact buffer | 16.5% (default) | Claude Code reserves part of the window for compaction. Overridden by the `CLAUDE_CODE_AUTO_COMPACT_WINDOW` env var (in tokens) when present. |
| Fallback window | 1,000,000 tokens | Used only if the runtime omits `total_tokens`. |
| Orchestrator target | < 40% | The accuracy-degradation zone begins around here; the first WARNING marks crossing it. |

## Thresholds

- **OK 0–40%** — healthy orchestrator; work normally.
- **WARNING 40–64%** — start delegating, prefer short tasks.
- **HIGH 65–79%** — accuracy compromised; finish + commit current task only.
- **CRITICAL 80%+** — save state and pause; the monitor writes a breadcrumb, and
  the bar shows a blinking skull.

(These bands are judged on the **raw** used% — the figure that matches `/context`.
The statusline bar's color may step up slightly earlier because it renders the
normalized value; see "Raw vs normalized" above.)

## Budgeting strategy

1. **The orchestrator is a coordinator, not a worker.** Its budget is spent on
   planning, routing, and holding decisions — not on raw file contents or test
   output. Push those into subagents.
2. **Each subagent gets a fresh window.** A task that would consume 40% of the
   orchestrator consumes a fraction of a fresh 200k subagent window and returns
   only a summary. That's the whole point of the architecture.
3. **Commits are context checkpoints.** Once work is committed, it lives on disk
   and can leave the window. Pause/compact/resume is safe precisely because the
   durable state (git + STATE.md) is complete.
4. **Tune to the model.** If you run a model with a different window, set it in
   `.claude/polis/config.json` so the percentages stay meaningful.

## config.json overrides

The context reading is real, so there's little to tune. The auto-compact buffer
is normally read from the `CLAUDE_CODE_AUTO_COMPACT_WINDOW` env var; the
orchestrator target is advisory:

```json
{
  "context": {
    "orchestratorTargetPct": 40
  }
}
```

The buffer default (16.5%) applies only when the env var is absent. The env var
is the runtime's own source of truth and is preferred.
