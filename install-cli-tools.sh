#!/usr/bin/env bash

# Install Codex, Gemini CLI, and Jules via npm
echo "Installing CLI tools via npm..."

# Fix for Nix/Permissions: Configure npm to use a writable user directory for global packages
NPM_GLOBAL="$HOME/.npm-global"
mkdir -p "$NPM_GLOBAL"
npm config set prefix "$NPM_GLOBAL"

# Install packages globally (without sudo)
npm install -g @openai/codex @google/gemini-cli @google/jules @anthropic/claude-code opencode-ai@latest @github/copilot

# Function to add to PATH if not present
add_to_path() {
    local shell_rc="$1"
    if [ -f "$shell_rc" ]; then
        if ! grep -q "$NPM_GLOBAL/bin" "$shell_rc"; then
            echo "Adding $NPM_GLOBAL/bin to PATH in $shell_rc"
            echo "" >> "$shell_rc"
            echo "# Added by install-cli-tools.sh" >> "$shell_rc"
            echo "export PATH=\"$NPM_GLOBAL/bin:\$PATH\"" >> "$shell_rc"
        else
            echo "$NPM_GLOBAL/bin is already in $shell_rc"
        fi
    fi
}

# Add to PATH in .bashrc and .zshrc
add_to_path "$HOME/.bashrc"
add_to_path "$HOME/.zshrc"

echo "Installation complete."
echo "Please restart your terminal or run 'source <your-shell-config>' to update your PATH."
