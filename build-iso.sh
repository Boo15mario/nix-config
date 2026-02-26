#!/usr/bin/env bash

# Build the custom ISO using the configuration in the root flake
echo "Building the access-OS ISO..."

nix --extra-experimental-features 'nix-command flakes' build .#iso -o access-os-iso

if [ $? -eq 0 ]; then
  echo "Build complete. The ISO can be found as 'access-os-iso'."
else
  echo "Build failed."
  exit 1
fi
