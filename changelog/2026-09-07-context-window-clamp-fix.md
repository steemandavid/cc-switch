# cc-switch — Changelog

## Fix Claude Code 200k context clamp on third-party models (v1.11)

**Date:** 2026-09-07
**Host:** john-ai

## 1. Problem

After a Claude Code update, launching `cc` with the z.ai backend printed:

> `"glm-5.3" isn't described by this version's model catalog; … auto-compact
> keeps this session within 200k tokens …`

Newer Claude Code versions check the selected model ID against a built-in
catalog of Anthropic models. Unknown IDs (all z.ai / Ollama models) get a
default 200k context assumption, so auto-compact fired far too early even
though GLM-5.3 actually has a 1M-token context window
(https://docs.z.ai/guides/llm/glm-5.3).

## 2. Fix (cc-switch v1.11 — 2026-09-07)

| Backend | Change |
|---|---|
| z.ai | Known GLM windows set via `CLAUDE_CODE_MAX_CONTEXT_TOKENS` (`glm-5.3` and `glm-5.3-flash` → 1000000); any other model falls back to `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1` (old wait-for-the-API behavior) |
| Ollama | Always sets `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1` — local model IDs are never in the catalog |
| Anthropic | Unsets both vars so a previous z.ai/Ollama session's overrides don't leak into a claude.ai session |

Version string bumped 1.10 → 1.11; README gained a "Context-window handling"
feature bullet.

## 3. Deployment gotcha — the running copy is NOT this repo

`~/.bashrc` sources `~/bin/cc-switch.sh`, which is a **symlink** to
`/home/john/claudecode/projects/claudecode-sync/bin/cc-switch.sh`
(git-tracked in the claudecode-sync repo). Editing only this dev repo has no
effect on the running `cc`. The patched v1.11 was copied over the
claudecode-sync copy and verified identical.

Also: this repo's `install.sh` copies to `~/bin/cc-switch` (no `.sh`) and adds
its own bashrc line — a path nothing sources. Don't rely on it for deployment.

Activate with `source ~/.bashrc` (existing shells keep the old functions).

## 4. Follow-ups

- Commit the v1.11 change in the **claudecode-sync** repo so the sync clone
  doesn't drift (noted to user; handled by the cc-switch repo's own commit
  here).
- When new GLM models appear (e.g. glm-5.4), add their context window to the
  `glm_context` map in `_cc_backend_zai` if known, or they'll get the
  disabled-enforcement fallback.
