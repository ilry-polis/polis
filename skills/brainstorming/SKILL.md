---
name: brainstorming
description: Use at the very start of any build request, before specs or code. Activates whenever the user describes something to build, fix, or change. Runs a Socratic exploration — questions, alternatives, trade-offs, gray areas — and produces an approved design document. The agent must NOT jump to code; this is the gate that enforces that.
---

# Brainstorming (Socratic)

The single most expensive mistake an agent makes is building the wrong thing
quickly. This skill exists to make sure that doesn't happen. When the user
describes something to build, you do not open an editor. You think with them
first.

## The non-negotiable

**Do not jump to code.** Not a scaffold, not a "quick draft," not a file. Until
there is an approved design, your job is to understand and shape the idea. If
the user explicitly insists on skipping ahead, you may — but record that the
design phase was skipped (see "Skipping" below) so it's visible later.

## How to run it

1. **Understand the real goal.** Ask what they're actually trying to accomplish,
   for whom, and why now. The stated feature is often a proxy for a deeper need.
   One question at a time — this is a conversation, not a form.

2. **Surface the gray areas.** Most designs die in the unspecified middle. Probe
   the parts that are ambiguous and consequential:
   - Data shapes and where state lives.
   - API/interface shapes — inputs, outputs, error cases.
   - Layout and interaction, if there's a UI.
   - Error handling and failure modes.
   - Scope edges: what's explicitly *out*.

3. **Explore alternatives and trade-offs.** Offer two or three ways to approach
   it, with honest trade-offs. Don't present a single path as if it were the
   only one. The user should see the fork before choosing it.

4. **Present in digestible chunks.** Share the emerging design a paragraph at a
   time — not a wall of text. After each chunk, pause for the user to confirm,
   correct, or redirect. The design is co-authored; you're holding the pen, not
   making the decisions.

5. **Converge.** When the shape is agreed, write it down.

## Output

Save the agreed design to `.claude/polis/specs/design-<feature>.md`. It should
capture: the goal, the chosen approach (and what was rejected and why), the
gray areas now resolved, explicit non-goals, and any open questions deferred to
the spec phase. This document is the input to `/polis:spec`.

## Skipping

If the user wants to skip discussion, honor it, but write a one-line note at the
top of the eventual spec: `Design phase skipped at user request.` This isn't a
punishment — it's a marker so that if the spec later turns out underspecified,
everyone knows why.

## Tone

Curious, not interrogating. Concrete, not abstract. You're a thinking partner
who asks the question the user hasn't thought to ask yet — and who's comfortable
saying "I'd push back on that, here's why."
