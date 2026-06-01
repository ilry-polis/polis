---
name: project-detect
description: Use at session start and whenever the project structure may have changed. Scans the repo to identify the language/framework ecosystem(s), then adapts lint, format, test, and commit commands accordingly. Handles monorepos with multiple ecosystems. Falls back to asking the user and saving the answer to config.json. Feeds TDD, review, and finishing-work.
---

# Project Detection

Polis is language-agnostic by design: nothing about the workflow is hardcoded to
a stack. This skill is how that promise is kept — it reads the project, figures
out what it's built with, and tells the rest of the system which commands to run.

## What it scans for

Look at the repository root (and, for monorepos, package subdirectories) for
ecosystem markers:

- `pubspec.yaml` → Flutter / Dart
- `package.json` → Node / JS / TS — then read it to identify the framework
  (Next.js, Astro, React, Vue, SvelteKit, etc.) and the package manager
  (npm / pnpm / yarn / bun via the lockfile)
- `requirements.txt` / `pyproject.toml` → Python (and the tool: poetry, uv, pip)
- `Cargo.toml` → Rust
- `go.mod` → Go
- `Gemfile` → Ruby
- `*.csproj` / `*.sln` → .NET
- `composer.json` → PHP
- `pom.xml` / `build.gradle` → Java / Kotlin (JVM)

This list is illustrative, not exhaustive. When you see a marker not listed
here, identify it from context rather than giving up.

## Monorepos

A repo can hold several ecosystems at once (e.g. a Next.js web app + a Python
service + a Dart mobile app). Detect each, note which directory each governs, and
adapt per-directory — the test command for the Python service is not the test
command for the web app. Don't flatten a monorepo into a single assumed stack.

## What it adapts

Once the stack is known, the rest of Polis uses it:

- **Test command** — what skills/tdd runs (pytest, vitest, go test, cargo test,
  dart test, ...).
- **Lint & format** — what skills/code-review checks (eslint/prettier, ruff,
  gofmt, clippy, ...).
- **Commit conventions** — match what the repo already does.
- **Deploy / build checklists** — what skills/finishing-work expects.
- **Expected directory structure** — so new files land where the project keeps
  them.

## When detection is uncertain

If the stack can't be identified confidently, **ask the user** rather than
guessing — a wrong assumption here quietly corrupts every command downstream.
Save the answer to `.claude/polis/config.json` so it's not asked again:

```json
{
  "stack": {
    "<dir-or-root>": {
      "ecosystem": "node",
      "framework": "nextjs",
      "packageManager": "pnpm",
      "test": "pnpm test",
      "lint": "pnpm lint",
      "format": "pnpm format"
    }
  }
}
```

## Re-detection

Project structure changes — a service gets added, a tool gets swapped. Re-scan
when the structure looks different from what's recorded in config.json, and
update the saved stack rather than running stale commands.
