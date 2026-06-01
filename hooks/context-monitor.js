#!/usr/bin/env node
/**
 * Polis :: context-monitor.js
 * ----------------------------------------------------------------------------
 * Runs as a Claude Code PostToolUse hook. Fires after every tool call.
 *
 * RESPONSIBILITIES:
 *   1. Read the REAL context usage. Two sources, in order of preference:
 *      (a) the PostToolUse payload, if it carries context_window info; else
 *      (b) the bridge file written by statusline.js, which stores the RAW
 *          used% (matching Claude Code's native /context readout).
 *   2. When a threshold is crossed, surface guidance to the model (via stderr).
 *   3. In CRITICAL, write a "crash breadcrumb" into STATE.md so no work is lost
 *      if the session is compacted or dies.
 *
 * RAW vs NORMALIZED:
 *   The monitor judges thresholds on the RAW used% (100 - remaining), matching
 *   the native /context numbers, so its CRITICAL fires in step with what the
 *   user sees in /context. (The statusline bar uses the NORMALIZED value, which
 *   intentionally warns earlier for action.) See statusline.js for the split.
 *
 * NOTE on PostToolUse limits:
 *   PostToolUse is observability-only: it CANNOT inject text into the model's
 *   prompt and CANNOT block. So guidance here goes to stderr (surfaced in
 *   verbose/transcript). The in-prompt nudge is delivered by the
 *   SessionStart/UserPromptSubmit hook + the context-mgmt skill. This file is
 *   the sensor; the skill is the voice.
 *
 * INPUT:  JSON on stdin (the PostToolUse payload).
 * OUTPUT: exit 0 always (never block the runtime). Notes go to stderr.
 *
 * SAFETY: a 10s timeout guard self-terminates so a stuck read never hangs the
 *         runtime.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execSync } from "node:child_process";

// ----------------------------------------------------------------------------
// Tunables.
// ----------------------------------------------------------------------------
const DEFAULT_AUTO_COMPACT_PCT = 16.5;
const DEFAULT_TOTAL_TOKENS = 1_000_000;
const TIMEOUT_MS = 10_000;

// Thresholds judged on RAW used% (matches native /context).
const THRESHOLDS = [
  { name: "OK", min: 0 },
  { name: "WARNING", min: 40 },
  { name: "HIGH", min: 65 },
  { name: "CRITICAL", min: 80 },
];

// ----------------------------------------------------------------------------
// Timeout guard: if anything hangs, exit cleanly so we never block the agent.
// ----------------------------------------------------------------------------
const guard = setTimeout(() => {
  process.exit(0);
}, TIMEOUT_MS);
guard.unref?.();

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------
function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

function bridgePath(sessionId) {
  const safe = String(sessionId || "default").replace(/[^a-zA-Z0-9_-]/g, "_");
  return path.join(os.tmpdir(), `polis-ctx-${safe}.json`);
}

function readBridge(p) {
  try {
    return JSON.parse(fs.readFileSync(p, "utf8"));
  } catch {
    return null;
  }
}

function bucketFor(percent) {
  let chosen = THRESHOLDS[0];
  for (const t of THRESHOLDS) if (percent >= t.min) chosen = t;
  return chosen.name;
}

/**
 * Resolve the project directory from the payload or env, then the STATE.md path.
 * We don't assume the path exists; the breadcrumb writer creates dirs as needed.
 */
function statePath(payload) {
  const cwd =
    payload.cwd ||
    payload.workspace_root ||
    process.env.CLAUDE_PROJECT_DIR ||
    process.cwd();
  return path.join(cwd, ".claude", "polis", "STATE.md");
}

/** Best-effort list of files changed since last commit. */
function changedFiles(cwd) {
  try {
    const out = execSync("git diff --name-only", {
      cwd,
      stdio: ["ignore", "pipe", "ignore"],
      timeout: 3000,
    }).toString();
    return out.split("\n").map((s) => s.trim()).filter(Boolean);
  } catch {
    return [];
  }
}

/**
 * Append a crash breadcrumb to STATE.md. We APPEND a clearly-marked block rather
 * than rewrite the file, so a human or resume-work can see exactly what the
 * monitor captured at the moment of CRITICAL.
 */
function writeBreadcrumb(payload) {
  const cwd =
    payload.cwd ||
    payload.workspace_root ||
    process.env.CLAUDE_PROJECT_DIR ||
    process.cwd();
  const sp = statePath(payload);
  const files = changedFiles(cwd);
  const ts = new Date().toISOString();
  const lastTool = payload.tool_name || payload.tool || "unknown";

  const block = [
    "",
    "<!-- POLIS:CRASH-BREADCRUMB -->",
    `## Stopped At (auto, CRITICAL) — ${ts}`,
    `- Trigger: context monitor crossed CRITICAL (80%+ of context used, matches /context).`,
    `- Last tool observed: ${lastTool}`,
    `- Uncommitted files (${files.length}): ${files.length ? files.join(", ") : "none detected"}`,
    `- Action required: run /polis:pause-work, then /compact, then /polis:resume-work.`,
    "<!-- /POLIS:CRASH-BREADCRUMB -->",
    "",
  ].join("\n");

  try {
    fs.mkdirSync(path.dirname(sp), { recursive: true });
    fs.appendFileSync(sp, block);
  } catch {
    /* best-effort */
  }
}

// ----------------------------------------------------------------------------
// Main
// ----------------------------------------------------------------------------
function main() {
  const raw = readStdin();
  let payload = {};
  try {
    payload = raw ? JSON.parse(raw) : {};
  } catch {
    payload = {};
  }

  const sessionId =
    payload.session_id ||
    payload.sessionId ||
    process.env.CLAUDE_SESSION_ID ||
    "default";

  // Determine the RAW used% from the real context window.
  // Source (a): payload carries context_window (preferred, freshest).
  // Source (b): the bridge file statusline.js wrote (raw_used_pct).
  let rawUsed = null;
  const remaining = Number(payload?.context_window?.remaining_percentage);
  if (Number.isFinite(remaining)) {
    rawUsed = Math.max(0, Math.min(100, Math.round(100 - remaining)));
  } else {
    const bridge = readBridge(bridgePath(sessionId));
    if (bridge && Number.isFinite(Number(bridge.raw_used_pct))) {
      rawUsed = Number(bridge.raw_used_pct);
    }
  }

  // No real context info available this turn -> nothing to judge; exit clean.
  if (rawUsed == null) {
    clearTimeout(guard);
    process.exit(0);
  }

  const threshold = bucketFor(rawUsed);

  // Surface guidance via stderr (PostToolUse cannot edit the prompt).
  // The context-mgmt skill turns these signals into in-prompt behavior.
  if (threshold === "WARNING") {
    process.stderr.write(
      "[polis] Context past 40% (WARNING). Start delegating heavy work to subagents and prefer short tasks.\n"
    );
  } else if (threshold === "HIGH") {
    process.stderr.write(
      "[polis] Context past 65% (HIGH). Accuracy compromised — finish the current task, commit, and prepare /polis:pause-work.\n"
    );
  } else if (threshold === "CRITICAL") {
    process.stderr.write(
      "[polis] CRITICAL (80%+). Saving a crash breadcrumb and requiring pause. Run /polis:pause-work -> /compact -> /polis:resume-work.\n"
    );
    writeBreadcrumb(payload);
  }

  clearTimeout(guard);
  process.exit(0);
}

main();
