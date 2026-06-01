---
description: Final verification before a feature leaves the workflow — full test suite, lint, acceptance criteria, holistic spec compliance, and no leftovers. Then prepare the merge/PR handoff and clean up Polis state. The last gate.
argument-hint: "[feature or milestone name]"
---

# /polis:verify

Verify a completed feature as a whole and prepare it to ship. Runs the
finishing-work skill (skills/finishing-work).

## What it does

1. **Final verification**, end to end (not task by task):
   - Full test suite green — the whole project's suite, to catch regressions.
   - Lint/format clean across the changed surface.
   - Every spec acceptance criterion satisfied by real, tested behavior.
   - Holistic spec compliance — the assembled feature matches the spec, not just
     each task in isolation.
   - No leftovers: no debug output, dead code, TODO/FIXME, commented-out
     experiments.
   If any check fails, route the fix back through `/polis:exec`, then re-verify.

2. **Prepare the handoff:** confirm the `[polis]` commit history reads as a
   coherent sequence; draft a PR/merge summary (what changed, why, which spec,
   how tested) tied back to spec and plan; surface anything a human reviewer must
   look at.

3. **Clean up state:** mark the milestone complete in STATE.md, clear any
   `Stopped At`, move a short milestone summary into `.claude/polis/history/`,
   leave specs/plans versioned in place.

## Boundary — stays with the human

Polis prepares; it does not unilaterally merge, push to a protected branch, open
or merge a PR, or change repo permissions/settings. Propose the action and let
the user approve or execute it.

## Then

Propose the next milestone or confirm the workflow is idle. Don't invent new
scope.
