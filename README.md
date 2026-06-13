# cc-switch

Interactive Claude Code backend switcher with provider and model selection.

## Features

- **Multiple backends**: Anthropic API (Claude Pro), z.ai, Ollama (local models)
- **Live model discovery**: Fetches available models from each provider
- **Smart model ordering**: Latest models preselected by default (reverse version sort); Anthropic models ordered by tier (opus → sonnet → haiku)
- **Interactive menus**: Arrow-key navigation with scroll support
- **Smart tier mapping**: Automatically maps opus/sonnet/haiku tiers for z.ai
- **Tool-calling detection**: Warns about Ollama models without tool support
- **Session recording**: Optional asciinema recording of Claude Code sessions
- **Sudo keepalive**: Pre-caches sudo credentials and keeps them alive for the entire Claude Code session via a background refresh loop that is stopped automatically when Claude exits (no password stored)

## Installation

1. Copy `cc-switch` to somewhere on your PATH:
   ```bash
   cp cc-switch ~/bin/cc-switch
   chmod +x ~/bin/cc-switch
   ```

2. Add to your `~/.bashrc`:
   ```bash
   source ~/bin/cc-switch
   ```

3. Configure API keys in `~/.bashrc`:
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   export ZAI_API_KEY="..."
   export ZAI_BASE_URL="https://api.z.ai/v1"  # optional override
   ```

4. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

## Usage

Run the interactive menu:
```bash
cc
```

Or jump directly to a backend:
```bash
cc-anthropic  # Anthropic API
cc-zai        # z.ai
cc-local      # Ollama
```

## Requirements

- `curl` for API requests
- `jq` or `python3` for JSON parsing
- Claude Code CLI installed
- `sudo` with `timestamp_type=global` (e.g. in `/etc/sudoers.d/`) so the keepalive can refresh the shared ticket; pair with a `timestamp_timeout` (e.g. 30) as a safety net

## License

MIT
