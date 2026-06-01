---
name: writing-specs
description: Use after a design is approved (via brainstorming) and before planning. Turns the agreed design into a technical spec precise enough that a subagent with zero project context could execute it. Activates on /polis:spec or when moving from design to implementation planning. Covers architecture, interfaces, edge cases, acceptance criteria, and anti-patterns.
---

# Writing Specs

A spec is a contract. Its job is to remove ambiguity so that implementation
becomes mechanical. The design phase decided *what* and *why*; the spec decides
*exactly what, precisely.*

## The quality test

**A good spec can be executed by a subagent that has never seen this project.**

This is the bar, and it's literal. In Polis, execution happens in fresh-context
subagents that don't share your conversation history. If the spec assumes
knowledge that only lives in your head or in this chat, the subagent will guess
— and guess wrong. So as you write, keep asking: *could a competent stranger
build this from these words alone?* If not, the gap is a defect in the spec.

## Required content

Every spec must contain all of these. If a section is genuinely N/A, say so
explicitly rather than omitting it.

1. **Architecture & technical decisions.** The structure, the key components,
   how they fit. Decisions made and the reasoning, so they aren't relitigated
   during execution.

2. **Interfaces & contracts.** The precise shapes: function signatures, API
   request/response schemas, data types, database schema changes. Names,
   types, nullability. This is where ambiguity hides — be exact.

3. **Edge cases & error handling.** What happens on empty input, on failure, on
   concurrent access, on the boundary values. How errors surface and what the
   caller sees. A spec that only describes the happy path is half a spec.

4. **Acceptance criteria — measurable.** How we *know* it's done. Each criterion
   must be checkable, ideally by a test. "Works correctly" is not a criterion;
   "returns 404 with body `{error: 'not found'}` for unknown ids" is.

5. **What NOT to do.** Project-specific anti-patterns — the wrong turns a
   subagent might take that look reasonable in isolation. (See
   references/anti-patterns.md for the general set; here you list the ones
   specific to this feature and codebase.)

## Process

1. Start from `specs/design-<feature>.md`. The design's resolved gray areas
   become spec sections; the design's open questions get answered here or
   flagged.
2. Draft the spec, then read it back through the eyes of a context-free
   subagent. Mark every place you'd have to ask a question.
3. Close those gaps.
4. **Review loop with the user:** present the spec, take feedback, adjust,
   repeat until they approve. The spec advances on approval, not on your
   judgment alone.

## Versioning

Save as `.claude/polis/specs/spec-<feature>-v<n>.md`. Each material revision is
a new version, not an overwrite — the history of how the contract evolved is
worth keeping. The latest approved version is the one `/polis:plan` consumes.

## Keep it tight

Precise is not the same as long. Cut prose that doesn't reduce ambiguity. A spec
earns its length in clarity, not volume.
