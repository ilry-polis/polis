# Context Budget — Rules & Rationale

This reference defines how Polis accounts for context, why the numbers are what
they are, and the honest limits of what Polis can actually measure.

## What Polis can and cannot measure

**Cannot:** None of the three supported runtimes hands a script the real
"tokens used / tokens total" figure for the live session. Claude Code's
statusline and hooks receive session metadata, but not a precise usage number.

**Can:** Polis observes the *size of tool inputs and outputs* as they flow
through the PostToolUse hook (Claude Code) or afterFileEdit/stop hooks (Cursor),
accumulates those bytes per session in a temp-dir bridge file, and converts to
an approximate token count.

So every Polis percentage is an **estimate**, and a conservative one. It
undercounts, because it never sees:

- the system prompt and tool definitions,
- prior conversation turns that predate the current tool stream,
- the model's own reasoning tokens.

The practical consequence: when Polis shows a percentage, the true figure is
higher. That is by design — the conservative estimate plus the bands sitting at
the ceiling means a WARNING is a real signal, not a false alarm.

## The numbers

| Quantity | Value | Why |
|---|---|---|
| Auto-compact reserve | 16.5% | Claude Code holds back ~1/6 of the window for compaction; that space is not yours to spend. |
| Usable window | 83.5% | What remains after the reserve. All Polis percentages are of this. |
| Assumed window | 200,000 tokens | Default when the runtime doesn't report the model's window. Override in config.json. |
| Bytes per token | ~4 | Crude heuristic for the byte→token conversion. Override in config.json. |
| Orchestrator target | < 40% | At the edge of the accuracy-degradation zone; the first WARNING marks crossing it. |

## Thresholds

- **OK 0–40%** — healthy orchestrator; work normally.
- **WARNING 41–60%** — past the ceiling; start delegating, prefer short tasks.
- **HIGH 61–75%** — accuracy compromised; finish + commit current task only.
- **CRITICAL 75%+** — save state and pause; the monitor writes a breadcrumb.

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

```json
{
  "context": {
    "windowTokens": 200000,
    "autoCompactReserve": 0.165,
    "bytesPerToken": 4,
    "orchestratorTargetPct": 40
  }
}
```

If a key is absent, the built-in default applies.
