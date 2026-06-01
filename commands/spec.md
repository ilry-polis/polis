---
description: Turn an approved design into an executable technical spec — precise enough for a context-free subagent to build from. Covers architecture, interfaces, edge cases, measurable acceptance criteria, and anti-patterns. Versioned and user-approved.
argument-hint: "[feature name]"
---

# /polis:spec

Write the technical spec for a feature whose design is agreed. Runs the
writing-specs skill (skills/writing-specs).

## What it does

1. Load `.claude/polis/specs/design-<feature>.md`. If it's missing, note that
   there's no approved design and offer `/polis:discuss` first (or proceed with
   the skip marker if the user insists).
2. Draft the spec with all required sections: architecture & decisions,
   interfaces & contracts, edge cases & error handling, measurable acceptance
   criteria, and a feature-specific "what NOT to do."
3. Apply the quality test: read it back as a context-free subagent would and
   close every spot that would force a question.
4. Run the review loop with the user — present, adjust, repeat — until approved.
5. Save as `.claude/polis/specs/spec-<feature>-v<n>.md` (new version on material
   change) and advance STATE.md's phase to `spec` → ready for `plan`.

## Reminders

- The bar is the quality test: executable by a stranger to the project.
- Precise, not padded. Length is earned in clarity, not volume.
- Advances on the user's approval, not on the agent's judgment alone.
