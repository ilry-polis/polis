---
name: roadmapping
description: Use after discuss (when a design and ID'd requirements exist) and before spec, for a NEW project or a large multi-phase effort. Decomposes the whole app into a sequence of phases — vertical slices, each an end-to-end verifiable capability — with goal-backward success criteria and 100% requirement coverage. Activates on /polis:roadmap. The roadmap is the project map; each phase is later taken through spec -> plan -> exec -> verify, one at a time.
---

# Roadmapping

Most projects are too big to spec in one pass. Roadmapping sits between discuss
and spec: it takes the whole approved design plus the ID'd requirements and cuts
the app into an ordered sequence of phases. Each phase becomes its own
discuss-light → spec → plan → exec → verify loop later. The roadmap is the map of
the whole journey; you still walk it one phase at a time.

This is for new projects and large efforts. A single small feature skips
roadmapping entirely — it goes straight discuss → spec → plan.

## Inputs

Roadmapping needs three things to already exist (produced by discuss):

- **The design** — `.claude/polis/specs/design-<project>.md`: vision, constraints,
  non-negotiables.
- **The requirements with IDs** — a `REQUIREMENTS.md` (or the requirements section
  of the design) where every requirement carries a categorized ID: `AUTH-01`,
  `INFRA-03`, `CRISIS-02`, and so on. The IDs are not decoration — they are what
  the coverage validator checks against. No IDs, no roadmap.
- **Granularity** — coarse / standard / fine (the user chooses; default standard).

If the requirements have no IDs, stop and go back to discuss to add them. The
roadmap cannot guarantee coverage over requirements it can't name.

## The core rule: phases are vertical slices

**Each phase is one end-to-end verifiable capability — not a horizontal layer.**

This is the single most important decision in the whole skill, and the easiest to
get wrong. The tempting-but-forbidden split is by technical layer:

> ❌ Phase 1: all the data models. Phase 2: all the APIs. Phase 3: all the UI.

That's horizontal, and it's wrong, because no phase delivers a working capability
until the last one — you can't verify anything end-to-end until the end. The
correct split is vertical:

> ✅ Phase 1: Foundation (a tenant-isolated DB you can prove is secure).
> ✅ Phase 2: Auth (a user can actually sign in). Phase 3: Patient CRUD (a user
> can manage real records).

Each vertical slice cuts through all the layers it needs and ends in something you
can demonstrate works. When a phase is done, a real capability exists.

## How to derive the phases

1. **Group requirements by natural category.** The IDs already cluster them —
   AUTH-*, CONTENT-*, INFRA-*, etc. The categories are the raw material for phases.
2. **Order by dependency.** What must exist first? Auth before patient data;
   foundation/security before anything touching real data; the async pipeline
   before the AI that runs on it. Dependencies set the sequence.
3. **Make each phase an end-to-end capability.** Bundle the requirements that
   together produce one verifiable outcome. If a group of requirements doesn't add
   up to something demonstrable, it's not a phase yet — fold it into one that is.
4. **Derive from the work first, compress second.** Don't decide "I want 8 phases"
   and pad to fit. Find the natural phases the work implies, *then* apply the
   granularity target as compression.

## Granularity is compression, not padding

The user's granularity choice is a tolerance for how much to merge or split the
natural phases — applied *after* deriving them, never before.

| Granularity | Phases | Plans per phase |
|---|---|---|
| coarse | 3–5 | 1–3 |
| standard | 5–8 | 3–5 |
| fine | 8–12 | 5–10 |

- **coarse** merges related capabilities into bigger phases — fewer checkpoints,
  faster to a working whole, less granular control.
- **fine** splits capabilities into smaller phases — more checkpoints, tighter
  control, more overhead.
- If the natural work yields 6 phases and the user asked for coarse, *merge* the
  most-related adjacent ones down to ~4. If they asked fine, *split* the largest
  into verifiable sub-capabilities up to ~9. Never invent filler phases to hit a
  number, and never cram unrelated work together just to reduce the count.

## Each phase's fields

Every phase in the roadmap carries:

- **Goal** — a user/system *outcome*, phrased as a capability, not a task. Not
  "Build auth" but "A user can securely sign in and the session is revocable."
- **Depends on** — the phase(s) that must complete first, or "Nothing."
- **Requirements** — the list of requirement IDs this phase satisfies.
- **Success Criteria** — 2–5 observable, checkable behaviors, derived
  *goal-backward* (see below). These are what verify the phase is done.
- **Plans** — `TBD` at roadmap time. They get filled in later when the phase is
  taken through `/polis:plan`. The roadmap does not plan tasks.

## Goal-backward success criteria

For each phase, don't list what you'll build — state what must be **TRUE** when
it's done. Work backward from the goal:

1. State the goal.
2. List 2–5 observable truths that would prove the goal is met. Observable means
   checkable — ideally by a test. "Auth works" is not a criterion; "A user signs
   in with email/password, gets a verification email, and can reset their
   password" is.
3. Cross-check both directions: does every criterion trace to a requirement? Does
   every requirement in the phase contribute to at least one criterion? If a
   criterion has no requirement, you invented scope — cut it or add the
   requirement. If a requirement contributes to nothing, the phase is missing a
   criterion.

## Coverage validation — non-negotiable

Before writing the roadmap, validate that **every v1 requirement maps to exactly
one phase.** Zero orphans (a requirement in no phase), zero duplicates (a
requirement in two phases).

- If a requirement fits nowhere, either create a phase for it or explicitly mark
  it out-of-scope / deferred to v2 — never silently drop it.
- If a requirement seems to belong to two phases, decide which one *owns* it; the
  other merely uses it.
- Report the coverage explicitly: "Coverage: 140/140 ✓" or name the orphans. A
  roadmap that can't account for every requirement is not done.

## Output

Write `.claude/polis/ROADMAP.md` (see references/roadmap-format.md for the exact
template). It has two levels, both required:

1. A **checklist** of phases (one-liner each) — the at-a-glance view.
2. **Phase Detail** sections with `### Phase N:` headers — these headers are a
   contract: `/polis:spec` and `/polis:plan` parse the roadmap by them to pull a
   phase's goal, requirements, and criteria. Don't reformat them freely.

Also: add a **Traceability** table (requirement → phase → status) to
REQUIREMENTS.md, and update STATE.md so the current milestone points at Phase 1
(phase `roadmap` → ready to `spec` the first phase).

## Numbering

Integer phases (1, 2, 3) for the planned sequence. If an urgent phase must be
inserted later between existing ones, use a decimal (2.1, 2.2) so downstream
references to the original numbers don't break.

## After the roadmap

The roadmap is approved by the user (review loop — adjust and re-validate until
they sign off), then committed. From there, work proceeds **one phase at a time**:
`/polis:spec <phase>` → `/polis:plan` → `/polis:exec` → `/polis:verify`, then back
for the next phase. The roadmap is the durable map; the per-phase loop is the
walking.

## What this skill is NOT

- Not task planning — that's `/polis:plan`, per phase, later.
- Not a spec — phases carry goals and criteria, not interfaces and edge cases.
- Not enterprise project management — no sprints, no estimates, no ceremony. A
  solo dev + Claude. The roadmap exists to sequence the work and guarantee
  coverage, nothing more.
