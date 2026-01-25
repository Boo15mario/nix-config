#!/usr/bin/env bash

# Build the custom ISO using the configuration in the custom-iso directory
echo "Building the access-nix ISO..."

# We use -o to name the symlink, though the internal volume ID is harder to change without 
# modifying the nixos configuration. We'll set the symlink to 'access-nix-iso'.
nix-build '<nixpkgs/nixos>' \
  -A config.system.build.isoImage \
  -I nixos-config=$(pwd)/custom-iso/configuration.nix \
  -o access-nix

if [ $? -eq 0 ]; then
  echo "Build complete. The ISO can be found in the 'access-nix' result directory."
else
  echo "Build failed."
  exit 1
fi
