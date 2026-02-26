# Nix Configuration Repository

This repository contains Nix configuration files for my systems and utility scripts.

## Nix Flakes

This repository has been converted to use **Nix Flakes**. This ensures reproducible builds and simplifies dependency management (like `access-nix` and `NUR`).

### Rebuilding a System

To apply changes to a specific system (e.g., `hp-boo`), run:
```bash
sudo nixos-rebuild switch --flake .#hp-boo
```

### Updating Packages

To update all inputs (e.g., fetching the latest commits for `access-nix`, `access-os-artwork`, etc.), run:
```bash
nix flake update
```
Then run the rebuild command for your system again.

### Building the access-OS ISO

To build the custom access-OS ISO, run:
```bash
./build-iso.sh
```

### Experimental Features

This configuration automatically enables `nix-command` and `flakes` on all systems. If you haven't enabled them yet, you may need to add the following flags to your first rebuild:
`--extra-experimental-features 'nix-command flakes'`

## Directory Structure

- **System Folders**: Each folder (e.g., `boo76`, `hp-boo`) contains the NixOS configuration files specific to that system.
- **Root Scripts**: The shell scripts located in the root directory are general-purpose utility scripts intended for use on all systems.
