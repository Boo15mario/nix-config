#!/usr/bin/env bash

# Install Codex, Gemini CLI, and Jules via npm
echo "Installing CLI tools via npm..."

# Install packages globally with their respective scopes
sudo npm install -g @openai/codex @google/gemini-cli @google/jules

echo "Installation complete."
