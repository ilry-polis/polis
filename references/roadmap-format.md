# ROADMAP.md Format

The exact structure `/polis:roadmap` produces and that `/polis:spec` and
`/polis:plan` parse. Referenced by skills/roadmapping.

Two levels are mandatory: a phase **checklist** (at-a-glance) and **Phase Detail**
sections. The `### Phase N:` headers are a parsing contract — downstream commands
read a phase's goal, requirements, and criteria by locating these headers. Keep
them exact.

## Template

```
# Roadmap: <Project>

**Created:** <date>
**Granularity:** <coarse | standard | fine>
**Coverage:** <X>/<X> v1 requirements mapped
**Timeline target:** <optional>

## Overview

<One paragraph describing the whole journey from start to finish — what the app
becomes, in what order, and why the phases sequence the way they do.>

## Phases

- [ ] **Phase 1: <Name>** — <one-line capability>
- [ ] **Phase 2: <Name>** — <one-line capability>
- [ ] **Phase 3: <Name>** — <one-line capability>

## Phase Details

### Phase 1: <Name>
**Goal**: <user/system outcome, phrased as a capability>
**Depends on**: Nothing
**Requirements**: <REQ-01, REQ-02, ...>
**Success Criteria** (what must be TRUE):
  1. <observable, checkable behavior>
  2. <observable, checkable behavior>
**Plans**: TBD

### Phase 2: <Name>
**Goal**: <...>
**Depends on**: Phase 1
**Requirements**: <...>
**Success Criteria** (what must be TRUE):
  1. <...>
  2. <...>
**Plans**: TBD

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. <Name> | 0/? | Not started | - |
| 2. <Name> | 0/? | Not started | - |

## Coverage Summary

**Total v1 requirements:** <X>
**Mapped:** <X>
**Unmapped:** 0

See REQUIREMENTS.md Traceability for the full requirement-to-phase mapping.
```

## Field rules

- **Goal** is an outcome, not a task. "Users can securely sign in," not "Build
  auth." If it starts with a verb like Build/Implement/Create, rewrite it as the
  capability that work produces.
- **Depends on** is `Nothing` or `Phase N` (one or more). It sets the build order
  and is what lets independent phases be reasoned about.
- **Requirements** are the IDs this phase owns. Every v1 ID appears in exactly one
  phase's list across the whole roadmap.
- **Success Criteria** are 2–5 observable truths, goal-backward. Each should be
  checkable, ideally by a test. Avoid "works correctly"; state the concrete,
  testable behavior.
- **Plans: TBD** stays TBD until the phase is taken through `/polis:plan`. The
  roadmap names *what* and *in what order*, never the tasks.

## Traceability table (in REQUIREMENTS.md)

Roadmapping also appends or updates a Traceability section in REQUIREMENTS.md:

```
## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 2 | Planned |
| INFRA-01 | Phase 1 | Planned |
```

This is the inverse view of the roadmap's per-phase requirement lists, and the
two must agree. If a requirement appears here against a phase, that phase's
Requirements line must include it, and vice versa.

## Why the headers are a contract

`/polis:spec <phase>` finds `### Phase <N>:` and reads the Goal, Requirements, and
Success Criteria beneath it as the approved design input for that phase — so the
phase's spec doesn't start from scratch. If the headers are reformatted or the
field labels (`**Goal**`, `**Requirements**`, `**Success Criteria**`) change, the
parse breaks. Treat the structure as fixed; vary only the content.
