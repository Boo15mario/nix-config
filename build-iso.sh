#!/usr/bin/env bash

# Build the custom ISO using the configuration in the root flake
echo "Building the access-OS ISO..."

# Ensure we have a place to put the result
RESULT_DIR="iso-result"
mkdir -p "$RESULT_DIR"

# Run the build. This produces a symlink 'result-iso'
nix --extra-experimental-features 'nix-command flakes' build .#iso -o result-iso

if [ $? -eq 0 ]; then
  # The actual ISO is inside the nix store path. We want to COPY it out so it's a real file.
  # We use -L to follow the symlink and find the real .iso file.
  ISO_PATH=$(readlink -f result-iso/iso/*.iso)
  ISO_NAME=$(basename "$ISO_PATH")
  
  echo "Copying $ISO_NAME from the nix store to $RESULT_DIR/..."
  cp "$ISO_PATH" "$RESULT_DIR/$ISO_NAME"
  
  # If run with sudo, make sure the user owns the file
  if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER" "$RESULT_DIR"
  fi
  
  # Clean up the symlink
  rm result-iso
  
  echo "Build complete. The ISO is located at: $RESULT_DIR/$ISO_NAME"
else
  echo "Build failed."
  exit 1
fi
