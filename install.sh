#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASHRC="$HOME/.bashrc"

# Ensure ~/.local/bin is on PATH (Claude Code installer may only add it to .zshrc)
if ! echo "$PATH" | tr ':' '\n' | grep -qxF "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"
    export PATH="$HOME/.local/bin:$PATH"
    echo "Added ~/.local/bin to PATH in $BASHRC"
fi

# Step 3: Copy script to ~/bin
mkdir -p ~/bin
cp "$SCRIPT_DIR/cc-switch" ~/bin/cc-switch
chmod +x ~/bin/cc-switch
echo "Copied cc-switch to ~/bin/"

# Step 4: Source cc-switch in .bashrc (if not already there)
if ! grep -q 'source ~/bin/cc-switch' "$BASHRC" 2>/dev/null; then
    echo '' >> "$BASHRC"
    echo '# Claude Code backend switcher' >> "$BASHRC"
    echo 'source ~/bin/cc-switch' >> "$BASHRC"
    echo "Added source line to $BASHRC"
else
    echo "source line already in $BASHRC, skipping"
fi

# Step 5: Add API key exports to .bashrc (if not already there)
for key in ANTHROPIC_API_KEY ZAI_API_KEY ZAI_BASE_URL; do
    if ! grep -q "export $key=" "$BASHRC" 2>/dev/null; then
        echo "export $key=" >> "$BASHRC"
    fi
done
echo "API key placeholders added to $BASHRC"
echo "Edit $BASHRC to fill in your keys."

# Step 6: Source .bashrc
# shellcheck source=/dev/null
source "$BASHRC"
echo "Sourced $BASHRC"

echo ""
echo "Done! Run 'cc' to start the interactive menu."
echo "Don't forget to set your API keys in $BASHRC."
