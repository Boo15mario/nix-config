#!/usr/bin/env bash

# Build the custom ISO using the configuration in the root flake
echo "Building the access-OS ISO..."

# Determine the real user's home directory
if [ -n "$SUDO_USER" ]; then
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_HOME="$HOME"
fi

RESULT_DIR="$REAL_HOME/access-os-iso-result"
mkdir -p "$RESULT_DIR"

# Run the build. This produces a symlink 'result-iso' in the current project directory
nix --extra-experimental-features 'nix-command flakes' build .#iso -o result-iso

if [ $? -eq 0 ]; then
  # The actual ISO is inside the nix store path. We want to COPY it out so it's a real file.
  ISO_PATH=$(readlink -f result-iso/iso/*.iso)
  ISO_NAME=$(basename "$ISO_PATH")
  
  echo "Copying $ISO_NAME from the nix store to $RESULT_DIR/..."
  cp "$ISO_PATH" "$RESULT_DIR/$ISO_NAME"
  
  # Ensure the user owns the folder and file in their home directory
  if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER" "$RESULT_DIR"
  fi
  
  # Clean up the symlink in the project directory
  rm result-iso
  
  echo "Build complete. The ISO is located at: $RESULT_DIR/$ISO_NAME"
else
  echo "Build failed."
  exit 1
fi
