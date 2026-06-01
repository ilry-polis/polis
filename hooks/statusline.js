#!/usr/bin/env node
/**
 * Polis :: statusline.js
 * ----------------------------------------------------------------------------
 * Renders the Polis context bar on the Claude Code statusline.
 *
 * CONTEXT SOURCE (real, not estimated):
 *   Claude Code passes a JSON payload on stdin that includes the live context
 *   window state: context_window.remaining_percentage and .total_tokens. Polis
 *   reads that directly -- no tokenization, no transcript scanning, no I/O
 *   accumulation. The number is ground truth from the runtime.
 *
 * NORMALIZATION (auto-compact buffer):
 *   Claude Code reserves part of the window for auto-compact. Polis scales the
 *   meter to the USABLE range so 100% means "compact is about to fire," not
 *   "physical window full." The buffer is read from the env var
 *   CLAUDE_CODE_AUTO_COMPACT_WINDOW (tokens) when present, else defaults to
 *   16.5%.
 *
 * NORMALIZED vs RAW (important):
 *   The displayed bar uses the NORMALIZED used% (against the usable range).
 *   But the bridge file written for context-monitor.js stores the RAW used%
 *   (100 - remaining), because the normalized value over-warns by ~13 points
 *   relative to Claude Code's own /context readout. Bar = normalized (action
 *   threshold); monitor = raw (matches native /context).
 *
 * OUTPUT: a single line printed to stdout (Claude Code renders it verbatim).
 *
 * THRESHOLDS (on normalized used%):
 *   green        < 40%   OK        normal work, healthy orchestrator
 *   yellow      40-64%   WARNING   start delegating / short tasks
 *   orange      65-79%   HIGH      accuracy compromised, finish current task
 *   blink red    >= 80%  CRITICAL  save state now, pause required (skull)
 *
 * SAFETY: 3s stdin timeout; all errors silently no-op so the prompt never breaks.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

// ----------------------------------------------------------------------------
// Tunables.
// ----------------------------------------------------------------------------
const DEFAULT_AUTO_COMPACT_PCT = 16.5; // fallback buffer if env var absent
const DEFAULT_TOTAL_TOKENS = 1_000_000; // fallback window if runtime omits it

const THRESHOLDS = [
  { name: "OK", min: 0, color: "\x1b[32m", glyph: "🟢" }, // green
  { name: "WARNING", min: 40, color: "\x1b[33m", glyph: "🟡" }, // yellow
  { name: "HIGH", min: 65, color: "\x1b[38;5;208m", glyph: "🟠" }, // orange
  { name: "CRITICAL", min: 80, color: "\x1b[5;31m", glyph: "💀" }, // blinking red
];
const RESET = "\x1b[0m";

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------

/** Read stdin synchronously; "" if nothing piped. */
function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

/** Bridge file path for a session id, inside the OS temp dir. */
function bridgePath(sessionId) {
  const safe = String(sessionId || "default").replace(/[^a-zA-Z0-9_-]/g, "_");
  return path.join(os.tmpdir(), `polis-ctx-${safe}.json`);
}

/** Write the RAW used% to the bridge for context-monitor.js. Never throws. */
function writeBridge(sessionId, rawUsed, normalizedUsed, threshold) {
  try {
    fs.writeFileSync(
      bridgePath(sessionId),
      JSON.stringify(
        {
          raw_used_pct: rawUsed,
          normalized_used_pct: normalizedUsed,
          threshold,
          timestamp: new Date().toISOString(),
          session_id: sessionId,
        },
        null,
        2
      )
    );
  } catch {
    /* best-effort */
  }
}

/** Threshold bucket for a normalized percent. */
function bucketFor(percent) {
  let chosen = THRESHOLDS[0];
  for (const t of THRESHOLDS) if (percent >= t.min) chosen = t;
  return chosen;
}

/** 10-segment bar like [████░░░░░░]. */
function renderBar(percent, color) {
  const filled = Math.max(0, Math.min(10, Math.floor(percent / 10)));
  const bar = "█".repeat(filled) + "░".repeat(10 - filled);
  return `${color}[${bar}]${RESET}`;
}

/**
 * Compute normalized + raw used% from the runtime payload.
 * Exported shape kept simple for testing.
 */
export function computeUsage(data, env = process.env) {
  const cw = data?.context_window;
  if (!cw) return null;

  // Claude Code provides both used_percentage and remaining_percentage.
  // Prefer the native used_percentage; fall back to 100 - remaining.
  let rawUsedReal = Number(cw.used_percentage);
  if (!Number.isFinite(rawUsedReal)) {
    const remaining = Number(cw.remaining_percentage);
    if (!Number.isFinite(remaining)) return null; // no real context this turn
    rawUsedReal = 100 - remaining;
  }
  const remaining = 100 - rawUsedReal;

  // Window size: the field is context_window_size (fallback total_tokens, then default).
  const totalCtx =
    Number(cw.context_window_size) || Number(cw.total_tokens) || DEFAULT_TOTAL_TOKENS;

  const acw = parseInt(env.CLAUDE_CODE_AUTO_COMPACT_WINDOW || "0", 10);
  const bufferPct =
    acw > 0 ? Math.min(100, (acw / totalCtx) * 100) : DEFAULT_AUTO_COMPACT_PCT;

  const usableRemaining = Math.max(
    0,
    ((remaining - bufferPct) / (100 - bufferPct)) * 100
  );
  const normalizedUsed = Math.max(0, Math.min(100, Math.round(100 - usableRemaining)));
  const rawUsed = Math.max(0, Math.min(100, Math.round(rawUsedReal)));

  return { normalizedUsed, rawUsed };
}

/** Render the statusline string for a payload. Exported for testing. */
export function renderStatusline(data, env = process.env) {
  const usage = computeUsage(data, env);
  if (!usage) {
    // No real context info available -- render a neutral, honest placeholder.
    return "Polis [──────────] context n/a";
  }
  const bucket = bucketFor(usage.normalizedUsed);
  const bar = renderBar(usage.normalizedUsed, bucket.color);
  return `${bucket.glyph} Polis ${bar} ${usage.normalizedUsed}% ${bucket.color}${bucket.name}${RESET}`;
}

// ----------------------------------------------------------------------------
// Main
// ----------------------------------------------------------------------------
function main() {
  // 3s guard so a stuck pipe never hangs the prompt.
  const guard = setTimeout(() => process.exit(0), 3000);
  guard.unref?.();

  const stdin = readStdin();
  let data = {};
  try {
    data = stdin ? JSON.parse(stdin) : {};
  } catch {
    data = {};
  }

  const sessionId =
    data.session_id || data.sessionId || process.env.CLAUDE_SESSION_ID || "default";

  const usage = computeUsage(data);
  if (usage) {
    const threshold = bucketFor(usage.normalizedUsed).name;
    // Bridge stores RAW used% (matches native /context); monitor reads it.
    writeBridge(sessionId, usage.rawUsed, usage.normalizedUsed, threshold);
  }

  process.stdout.write(renderStatusline(data));
  clearTimeout(guard);
}

// Only run main when executed directly, not when imported for testing.
import { fileURLToPath } from "node:url";
if (process.argv[1] && fileURLToPath(import.meta.url) === fs.realpathSync(process.argv[1])) {
  main();
}
