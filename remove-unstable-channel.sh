#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  echo "Error: This script should not be run as root. Please run it as a normal user (it will prompt for sudo when necessary)."
  exit 1
fi

echo "Removing nixos-unstable channel..."
sudo nix-channel --remove nixos
echo "Updating all Nix channels..."
sudo nix-channel --update

echo "NixOS unstable channel has been removed and all channels updated."
echo "You may need to rebuild your system for changes to take effect (e.g., sudo nixos-rebuild switch)."
