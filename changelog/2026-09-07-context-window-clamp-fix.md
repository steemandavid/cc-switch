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

## 4. Verification (later session, 2026-09-07)

End-to-end check confirmed the fix is live everywhere:

- Dev repo: commit `e1cf7b4` (v1.11) contains all three backend changes.
- Deploy chain: `~/.bashrc:127` → `~/bin/cc-switch.sh` (symlink) →
  `claudecode-sync/bin/cc-switch.sh`, which is **byte-identical** to the dev
  repo copy and matches its own committed version (`cbe977b` in the
  claudecode-sync repo — the follow-up below is done).
- `bash -n` passes on the deployed script.
- Logic check: in `_cc_backend_zai` the disable-var is unset before the
  known-model lookup, so `CLAUDE_CODE_MAX_CONTEXT_TOKENS` and
  `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT` are mutually
  exclusive in every path.
- Caveat repeated: shells opened before the deploy still hold v1.10 functions;
  `source ~/.bashrc` refreshes them.

## 5. Follow-ups

- ~~Commit the v1.11 change in the **claudecode-sync** repo~~ — done
  (`cbe977b`, verified this session).
- When new GLM models appear (e.g. glm-5.4), add their context window to the
  `glm_context` map in `_cc_backend_zai` if known, or they'll get the
  disabled-enforcement fallback.
