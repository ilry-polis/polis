---
description: Start Socratic brainstorming for something to build, before any spec or code. Explores goals, alternatives, trade-offs, and gray areas, then saves an approved design. The agent does not jump to code.
argument-hint: "[what you want to build]"
---

# /polis:discuss

Open the design phase for a new piece of work. This command runs the
brainstorming skill (skills/brainstorming) — it does not write code.

## What it does

1. Take `$ARGUMENTS` as the starting description of what to build (if empty, ask
   what they want to build).
2. Run the Socratic process: understand the real goal, surface the gray areas
   (data, interfaces, layout, error handling, scope edges), explore alternatives
   with honest trade-offs, present the design in digestible chunks the user
   confirms one at a time.
3. On convergence, save the agreed design to
   `.claude/polis/specs/design-<feature>.md` and update STATE.md's phase to
   `discuss` → ready for `spec`.

## Reminders

- Do not jump to code. If the user insists on skipping, honor it but record
  `Design phase skipped at user request` for the eventual spec.
- One question at a time; this is a conversation, not a form.
- The output of this command is an approved design, which becomes the input to
  `/polis:spec`.
