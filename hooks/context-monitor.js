#!/usr/bin/env node
/**
 * Polis :: context-monitor.js
 * ----------------------------------------------------------------------------
 * Runs as a Claude Code PostToolUse hook. Fires after every tool call.
 *
 * RESPONSIBILITIES:
 *   1. Accumulate an ESTIMATE of context usage by adding the byte-size of this
 *      tool call's input + output to a per-session bridge file in os.tmpdir().
 *      (statusline.js reads this same file to draw the bar.)
 *   2. Compute the usable-context percentage and, when a threshold is crossed,
 *      surface guidance to the model.
 *   3. In CRITICAL, write a "crash breadcrumb" into the project's STATE.md so
 *      no work is lost if the session is compacted or dies.
 *
 * HONEST LIMITATIONS (read this):
 *   - Claude Code does NOT give hooks the real context percentage, so this is
 *     an estimate from observed tool I/O. It will undercount tokens it never
 *     sees (e.g. the system prompt, prior turns) and is therefore conservative
 *     about how much HEADROOM exists -- by design.
 *   - PostToolUse is observability-only: it CANNOT inject text into the model's
 *     prompt and CANNOT block. So "injecting a warning" here means printing a
 *     structured note to stderr (which Claude Code surfaces in verbose/transcript)
 *     AND recording the threshold in the bridge file. The actual in-prompt nudge
 *     is delivered by a SessionStart/UserPromptSubmit hook + the context-mgmt
 *     skill, which CAN add context. This file is the sensor; the skill is the voice.
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
// Tunables (mirror statusline.js; config.json may override).
// ----------------------------------------------------------------------------
const AUTO_COMPACT_RESERVE = 0.165;
const DEFAULT_WINDOW_TOKENS = 200_000;
const APPROX_BYTES_PER_TOKEN = 4;
const TIMEOUT_MS = 10_000;

const THRESHOLDS = [
  { name: "OK", min: 0 },
  { name: "WARNING", min: 41 },
  { name: "HIGH", min: 61 },
  { name: "CRITICAL", min: 75 },
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

function writeBridge(p, data) {
  try {
    fs.writeFileSync(p, JSON.stringify(data, null, 2));
  } catch {
    /* best-effort; never throw */
  }
}

function bucketFor(percent) {
  let chosen = THRESHOLDS[0];
  for (const t of THRESHOLDS) if (percent >= t.min) chosen = t;
  return chosen.name;
}

/** Byte-size of an arbitrary value once serialized. */
function sizeOf(value) {
  if (value == null) return 0;
  try {
    return Buffer.byteLength(
      typeof value === "string" ? value : JSON.stringify(value),
      "utf8"
    );
  } catch {
    return 0;
  }
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
    `- Trigger: context monitor crossed CRITICAL (~75%+ usable).`,
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
  const windowTokens =
    Number(payload.model?.context_window) ||
    Number(payload.context_window) ||
    DEFAULT_WINDOW_TOKENS;

  // Size of this tool call (input + output), in bytes.
  const inBytes = sizeOf(payload.tool_input ?? payload.input);
  const outBytes = sizeOf(payload.tool_response ?? payload.tool_output ?? payload.output);
  const deltaBytes = inBytes + outBytes;

  // Accumulate into the bridge file.
  const bp = bridgePath(sessionId);
  const prev = readBridge(bp) || { used_bytes: 0 };
  const usedBytes = Number(prev.used_bytes || 0) + deltaBytes;

  const estimatedTokens = usedBytes / APPROX_BYTES_PER_TOKEN;
  const usableTokens = windowTokens * (1 - AUTO_COMPACT_RESERVE);
  const percent = Math.max(0, Math.min(100, (estimatedTokens / usableTokens) * 100));
  const rounded = Math.round(percent);
  const threshold = bucketFor(rounded);

  writeBridge(bp, {
    used_bytes: usedBytes,
    percent_used: rounded,
    threshold,
    timestamp: new Date().toISOString(),
    session_id: sessionId,
  });

  // Surface guidance via stderr (PostToolUse cannot edit the prompt).
  // The context-mgmt skill turns these signals into in-prompt behavior.
  if (threshold === "WARNING") {
    process.stderr.write(
      "[polis] Context past 40% (WARNING). Orchestrator past its ceiling — start delegating to subagents and prefer short tasks.\n"
    );
  } else if (threshold === "HIGH") {
    process.stderr.write(
      "[polis] Context above 60% (HIGH). Accuracy compromised — finish the current task, commit, and prepare /polis:pause-work.\n"
    );
  } else if (threshold === "CRITICAL") {
    process.stderr.write(
      "[polis] CRITICAL (~75%+). Saving a crash breadcrumb and requiring pause. Run /polis:pause-work -> /compact -> /polis:resume-work.\n"
    );
    writeBreadcrumb(payload);
  }

  clearTimeout(guard);
  process.exit(0);
}

main();
