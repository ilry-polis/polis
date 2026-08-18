# Context Budget — Rules & Rationale

Polis protects context quality **and** token efficiency. A fresh subagent window
can reduce context pollution, but every subagent also performs its own model and
tool work. The correct goal is not "delegate everything"; it is "keep each
thread focused while minimizing unnecessary model turns."

## What Polis measures

When a runtime exposes real context usage, Polis reads it. When it does not,
Polis stays silent rather than fabricating precision.

## Thresholds

- **OK 0–40%** — healthy.
- **WARNING 40–64%** — reduce broad reads/output; finish the current batch.
- **HIGH 65–79%** — finish/checkpoint current work only.
- **CRITICAL 80%+** — save state and pause/resume with fresh context.

These thresholds are context-health signals, **not automatic delegation
triggers**.

## Token-efficient budgeting strategy

1. **Shrink before spawning.** Prefer file anchors, targeted reads/searches,
   concise command output, git commits, and STATE.md over loading raw history.
2. **Batch related implementation.** One fresh runner may execute 1–3 related
   tasks sequentially, preserving one TDD cycle and atomic commit per task.
3. **Delegate for a reason.** Use a subagent for isolation, noisy exploration,
   high-risk separation, or real parallel speedup — not because a task exists.
4. **Cap write parallelism.** Default maximum: 2 concurrent runners. Read-heavy
   exploration may parallelize when useful, but avoid write-heavy fan-out.
5. **No nested agents.** Polis runner depth is 1.
6. **No polling loops.** One wait for a wave; if needed, useful coordinator work
   followed by at most one later wait. Status checks are not progress.
7. **Reuse local context, not global history.** A runner gets plan/spec anchors
   and reads named files itself. It returns a concise outcome, not transcript.
8. **Verify at the right boundary.** Targeted checks per task/batch; full suite at
   meaningful integration boundaries and `/polis:verify`.
9. **Commits are context checkpoints.** Once work is committed, details can leave
   the active window; STATE.md stores only durable facts.

## Default project orchestration config

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

These defaults intentionally trade a little theoretical parallelism for a much
smaller orchestration surface. Users can choose `reviewMode: strict` when they
want stronger per-task ceremony and accept the extra model/tool work.
