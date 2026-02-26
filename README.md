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

## Fresh Install / Reinstalling

To install NixOS using this repository from a live environment:

1. **Mount your partitions**:
   ```bash
   # Adjust to your actual drive/partition scheme
   sudo mount /dev/sda2 /mnt
   sudo mkdir -p /mnt/boot
   sudo mount /dev/sda1 /mnt/boot
   ```

2. **Clone the repository**:
   ```bash
   sudo git clone https://github.com/Boo15mario/nix-config /mnt/etc/nixos
   ```

3. **Generate your hardware config**:
   Each machine needs its own hardware file. Generate it and move it to the correct host folder:
   ```bash
   sudo nixos-generate-config --root /mnt
   sudo mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hp-boo/hardware-configuration.nix
   ```

4. **Install using Flakes**:
   ```bash
   # Replace 'hp-boo' with your hostname
   sudo nixos-install --flake /mnt/etc/nixos#hp-boo --extra-experimental-features 'nix-command flakes'
   ```

## Directory Structure

- **System Folders**: Each folder (e.g., `boo76`, `hp-boo`) contains the NixOS configuration files specific to that system.
- **Root Scripts**: The shell scripts located in the root directory are general-purpose utility scripts intended for use on all systems.
