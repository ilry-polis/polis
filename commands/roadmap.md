---
description: Decompose an approved design + ID'd requirements into a phased roadmap — vertical-slice phases, goal-backward success criteria, and 100% requirement coverage. For new projects and large multi-phase efforts. Runs between discuss and spec.
argument-hint: "[project name] [coarse|standard|fine]"
---

# /polis:roadmap

Turn the whole approved design into an ordered sequence of phases. Runs the
roadmapping skill (skills/roadmapping). Use it once per project (or large effort),
after discuss, before specing the first phase.

## What it does

1. **Check inputs.** Confirm there's an approved design
   (`.claude/polis/specs/design-<project>.md`) and requirements **with IDs**
   (REQUIREMENTS.md or the design's requirements section). If requirements lack
   IDs, stop and send the user back to `/polis:discuss` to add them — coverage
   can't be validated otherwise.

2. **Resolve granularity** from `$ARGUMENTS` (coarse / standard / fine). If not
   given, default to standard and say so. Record it in config.json.

3. **Derive the phases** (skills/roadmapping):
   - Group requirements by category, order by dependency, make each phase an
     end-to-end **vertical-slice capability** — never a horizontal layer.
   - Derive the natural phases first, then apply granularity as compression
     (merge for coarse, split for fine), never as padding.

4. **Write goal-backward success criteria** — 2–5 observable, checkable truths
   per phase, cross-checked against the requirements both ways.

5. **Validate coverage** — every v1 requirement maps to exactly one phase. Zero
   orphans, zero duplicates. Report it explicitly (`Coverage: X/X ✓`) or name the
   gaps and resolve them (new phase, or mark out-of-scope) before writing.

6. **Write the artifacts:**
   - `.claude/polis/ROADMAP.md` (see references/roadmap-format.md — two levels,
     `### Phase N:` headers are a parse contract).
   - Traceability table (requirement → phase) appended/updated in REQUIREMENTS.md.
   - STATE.md updated: milestone → Phase 1, phase → `roadmap` (ready to spec).

7. **Review loop.** Present the roadmap, take feedback, adjust, re-validate
   coverage, repeat until the user approves. Then it's ready to commit.

## Output to the user

A short summary block: number of phases, granularity, coverage (X/X ✓), a
phase → goal → requirements table, and a preview of Phase 1's success criteria.
Then the suggested next step: `/polis:spec <phase-1>`.

## Reminders

- Phases are vertical slices (verifiable capabilities), never horizontal layers
  (models/APIs/UI).
- The roadmap names *what* and *in what order* — never the tasks. Tasks come later,
  per phase, via `/polis:plan`.
- Work proceeds one phase at a time after this: spec → plan → exec → verify, then
  the next phase.
- Solo dev + Claude. No sprints, estimates, or ceremony — just sequence and
  coverage.
