---
name: finishing-work
description: Use when a feature's tasks are complete and it's time to finalize. Activates on /polis:verify and at the end of a milestone. Runs final verification against the spec (tests, lint, acceptance criteria), prepares the merge/PR, and cleans up Polis state so the next milestone starts clean. The last gate before the work leaves the workflow.
---

# Finishing Work

Finishing is a distinct phase, not an afterthought. A feature isn't done when the
last task's test goes green — it's done when the whole thing has been verified as
a unit against the spec, the history is clean, and the workflow state is reset for
what comes next.

## Final verification

Before anything ships, verify the feature as a whole — not task by task, but
end to end:

1. **Full test suite green.** Run the project's complete suite (via
   skills/project-detect), not just the tests touched this milestone. Catch
   regressions in code that wasn't directly changed.
2. **Lint & format clean** across the changed surface.
3. **Acceptance criteria met.** Walk the spec's acceptance criteria one by one
   and confirm each is satisfied by real, tested behavior — not by assumption.
4. **Spec compliance, holistically.** The tasks each passed review, but does the
   assembled feature actually match what the spec described? Integration gaps
   live between tasks that were individually fine.
5. **No leftovers.** No debug output, no dead code, no TODO/FIXME in production,
   no commented-out experiments.

If any check fails, it's not finished — route the fix back through execution,
then re-verify.

Every check here is run-and-read, not assumed (skills/verification-before-completion):
the suite is green because you ran it and saw it, the criteria are met because you
demonstrated each — not because the tasks "should" add up.

## Prepare the handoff (merge / PR)

Once verified, prepare the work to leave the workflow:

- Ensure the branch's history is coherent — atomic `[polis]` commits that read
  as a sensible sequence.
- Draft a PR/merge summary: what changed, why, which spec it implements, how it
  was tested. Tie it back to the spec and plan so a reviewer has the trail.
- Surface anything a human reviewer specifically needs to look at.

**Boundaries — these stay with the human.** Polis prepares; it does not unilaterally:
- merge or push to a protected branch,
- open or merge a PR without the user's go-ahead,
- change repository settings, permissions, or sharing.
Propose the action and let the user execute or explicitly approve it.

## Clean up state

A finished milestone shouldn't leave stale breadcrumbs for the next one:

- Update STATE.md: mark the milestone complete, clear any `Stopped At`
  breadcrumb, record the final commit.
- Move the milestone's summary into `.claude/polis/history/` — a short record of
  what was built and decided, not the full transcript.
- Leave specs and plans versioned in place; they're the durable record of intent.

## Then what

End by proposing the next milestone, or confirming the work is complete and the
workflow is idle. Don't invent new scope — surface options and let the user
choose the next thing to build.
