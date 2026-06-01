#!/usr/bin/env node
/**
 * Polis :: statusline.js
 * ----------------------------------------------------------------------------
 * Renders the Polis context bar on the Claude Code statusline.
 *
 * HONEST LIMITATION (read this):
 *   Claude Code does NOT expose the real context-window percentage to scripts.
 *   The statusline script receives a JSON payload on stdin describing the
 *   session, but not a precise "tokens used / tokens total" figure. So Polis
 *   ESTIMATES usage by accumulating the byte-size of tool inputs+outputs that
 *   the PostToolUse hook (context-monitor.js) records in a shared bridge file.
 *   This is a heuristic, not ground truth. It is deliberately conservative:
 *   we'd rather warn early than warn late.
 *
 * DATA FLOW:
 *   context-monitor.js  --(writes)-->  bridge.json  --(reads)-->  statusline.js
 *
 * The bridge file lives in os.tmpdir() so it works cross-platform and never
 * pollutes the repo. It is keyed by session id.
 *
 * OUTPUT: a single line printed to stdout (Claude Code renders it verbatim).
 *
 * THRESHOLDS (percent of USABLE context, see below):
 *   green   0-40%   OK        normal work, healthy orchestrator
 *   yellow  41-60%  WARNING   past the ceiling, start delegating / short tasks
 *   orange  61-75%  HIGH      accuracy compromised, finish current task only
 *   red     75%+    CRITICAL  save state now, pause required
 *
 * USABLE CONTEXT:
 *   Claude Code reserves ~16.5% of the window for auto-compact. Polis treats
 *   the remaining 83.5% as the "usable" budget and reports the percentage of
 *   THAT, so the thresholds reflect real working headroom rather than raw size.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

// ----------------------------------------------------------------------------
// Tunables. Kept here (not hardcoded elsewhere) so config.json can override.
// ----------------------------------------------------------------------------
const AUTO_COMPACT_RESERVE = 0.165; // ~16.5% reserved by Claude Code
const DEFAULT_WINDOW_TOKENS = 200_000; // assumed model window if unknown
const APPROX_BYTES_PER_TOKEN = 4; // crude tokens<->bytes heuristic

const THRESHOLDS = [
  { name: "OK", min: 0, color: "\x1b[32m", glyph: "🟢" }, // green
  { name: "WARNING", min: 41, color: "\x1b[33m", glyph: "🟡" }, // yellow
  { name: "HIGH", min: 61, color: "\x1b[38;5;208m", glyph: "🟠" }, // orange
  { name: "CRITICAL", min: 75, color: "\x1b[31m", glyph: "🔴" }, // red
];
const RESET = "\x1b[0m";

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------

/** Read all of stdin synchronously; return "" if nothing is piped. */
function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

/** Bridge file path for a given session id, inside the OS temp dir. */
function bridgePath(sessionId) {
  const safe = String(sessionId || "default").replace(/[^a-zA-Z0-9_-]/g, "_");
  return path.join(os.tmpdir(), `polis-ctx-${safe}.json`);
}

/** Read the bridge file written by context-monitor.js. Never throws. */
function readBridge(sessionId) {
  try {
    const raw = fs.readFileSync(bridgePath(sessionId), "utf8");
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

/** Pick the threshold bucket for a given percent. */
function bucketFor(percent) {
  let chosen = THRESHOLDS[0];
  for (const t of THRESHOLDS) if (percent >= t.min) chosen = t;
  return chosen;
}

/** Render a 10-segment bar like [████░░░░░░]. */
function renderBar(percent, color) {
  const filled = Math.max(0, Math.min(10, Math.round(percent / 10)));
  const bar = "█".repeat(filled) + "░".repeat(10 - filled);
  return `${color}[${bar}]${RESET}`;
}

// ----------------------------------------------------------------------------
// Main
// ----------------------------------------------------------------------------
function main() {
  const stdin = readStdin();

  // Claude Code passes a session JSON on stdin. We only need the session id
  // (and the model window, if present) -- everything else is ignored.
  let session = {};
  try {
    session = stdin ? JSON.parse(stdin) : {};
  } catch {
    session = {};
  }

  const sessionId =
    session.session_id || session.sessionId || process.env.CLAUDE_SESSION_ID || "default";
  const windowTokens =
    Number(session.model?.context_window) ||
    Number(session.context_window) ||
    DEFAULT_WINDOW_TOKENS;

  const bridge = readBridge(sessionId);

  // Estimate used tokens from accumulated tool I/O bytes (heuristic).
  const usedBytes = Number(bridge?.used_bytes) || 0;
  const estimatedTokens = usedBytes / APPROX_BYTES_PER_TOKEN;

  // Usable budget = window minus the auto-compact reserve.
  const usableTokens = windowTokens * (1 - AUTO_COMPACT_RESERVE);
  const percent = Math.max(0, Math.min(100, (estimatedTokens / usableTokens) * 100));
  const rounded = Math.round(percent);

  const bucket = bucketFor(rounded);
  const bar = renderBar(rounded, bucket.color);

  // Final statusline. "~" signals this is an estimate, on purpose.
  process.stdout.write(
    `${bucket.glyph} Polis ${bar} ~${rounded}% ${bucket.color}${bucket.name}${RESET}`
  );
}

main();
