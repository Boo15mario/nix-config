#!/usr/bin/env bash
# Install this flake from a NixOS live environment.
#
# This script ERASES the selected system disk and, if selected, the home disk.
set -Eeuo pipefail

readonly MOUNT_POINT=/mnt
readonly DEFAULT_REPOSITORY=https://github.com/Boo15mario/nix-config.git

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_root() {
  [[ $EUID -eq 0 ]] || die "Run this script as root (for example: sudo $0)."
}

require_commands() {
  local command
  for command in chmod fallocate git grep install lsblk mkdir mkswap mount parted \
    partprobe sed swapon udevadm mkfs.fat mkfs.xfs umount nixos-enter \
    nixos-generate-config nixos-install; do
    command -v "$command" >/dev/null || die "Required command is missing: $command"
  done
}

partition_path() {
  local disk=$1 number=$2
  if [[ $disk =~ [0-9]$ ]]; then
    printf '%sp%s\n' "$disk" "$number"
  else
    printf '%s%s\n' "$disk" "$number"
  fi
}

validate_disk() {
  local disk=$1
  [[ -b $disk ]] || die "$disk is not a block device."
  [[ $(lsblk -dn -o TYPE "$disk") == disk ]] || die "$disk is not a whole disk."
  [[ -z $(lsblk -nr -o MOUNTPOINT "$disk") ]] || die "$disk or one of its partitions is mounted."
}

confirm_erase() {
  local disk=$1 response
  printf '\nThe following disk will be ERASED: %s\n' "$disk"
  lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS "$disk"
  read -r -p "Type ERASE $disk to continue: " response
  [[ $response == "ERASE $disk" ]] || die "Disk erase was not confirmed."
}

create_system_partitions() {
  local disk=$1
  parted --script "$disk" -- mklabel gpt
  parted --script "$disk" -- mkpart ESP fat32 1MiB 513MiB
  parted --script "$disk" -- set 1 esp on
  parted --script "$disk" -- mkpart nixos-root xfs 513MiB 100%
  partprobe "$disk"
  udevadm settle
}

create_home_partition() {
  local disk=$1
  parted --script "$disk" -- mklabel gpt
  parted --script "$disk" -- mkpart nixos-home xfs 1MiB 100%
  partprobe "$disk"
  udevadm settle
}

main() {
  require_root
  require_commands

  echo "Available disks:"
  lsblk -d -o NAME,SIZE,MODEL,TYPE

  local system_disk home_disk root_partition efi_partition home_partition
  local host swap_size repository username

  read -r -p "System disk to erase (for example /dev/nvme0n1): " system_disk
  validate_disk "$system_disk"
  confirm_erase "$system_disk"

  create_system_partitions "$system_disk"
  efi_partition=$(partition_path "$system_disk" 1)
  root_partition=$(partition_path "$system_disk" 2)
  mkfs.fat -F 32 -n EFI "$efi_partition"
  mkfs.xfs -f -L nixos-root "$root_partition"

  mount -t xfs "$root_partition" "$MOUNT_POINT"
  mkdir -p "$MOUNT_POINT/boot" "$MOUNT_POINT/home"
  mount "$efi_partition" "$MOUNT_POINT/boot"

  read -r -p "Use a separate disk for /home? [y/N]: " home_disk
  if [[ $home_disk =~ ^[Yy]$ ]]; then
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL,TYPE
    read -r -p "Home disk to erase: " home_disk
    [[ $home_disk != "$system_disk" ]] || die "The home disk must differ from the system disk."
    validate_disk "$home_disk"
    confirm_erase "$home_disk"
    create_home_partition "$home_disk"
    home_partition=$(partition_path "$home_disk" 1)
    mkfs.xfs -f -L nixos-home "$home_partition"
    mount -t xfs "$home_partition" "$MOUNT_POINT/home"
  fi

  read -r -p "Swapfile size (for example 16G; leave blank for none): " swap_size
  if [[ -n $swap_size ]]; then
    [[ $swap_size =~ ^[1-9][0-9]*[KMGT]?$ ]] || die "Use a positive size such as 16G or 8192M."
    fallocate -l "$swap_size" "$MOUNT_POINT/swapfile"
    chmod 600 "$MOUNT_POINT/swapfile"
    mkswap "$MOUNT_POINT/swapfile"
    swapon "$MOUNT_POINT/swapfile"
  fi

  read -r -p "NixOS host profile [boo76-main]: " host
  host=${host:-boo76-main}
  [[ $host =~ ^[A-Za-z0-9][A-Za-z0-9-]*$ ]] || die "Invalid host profile name."

  read -r -p "Repository URL [$DEFAULT_REPOSITORY]: " repository
  repository=${repository:-$DEFAULT_REPOSITORY}
  git clone "$repository" "$MOUNT_POINT/etc/nixos"
  [[ -f "$MOUNT_POINT/etc/nixos/flake.nix" ]] || die "The repository does not contain flake.nix."
  [[ -f "$MOUNT_POINT/etc/nixos/$host/configuration.nix" ]] || die "Host profile '$host' does not exist in the repository."

  nixos-generate-config --root "$MOUNT_POINT"
  mkdir -p "$MOUNT_POINT/etc/nixos/$host"
  install -m 644 "$MOUNT_POINT/etc/nixos/hardware-configuration.nix" \
    "$MOUNT_POINT/etc/nixos/$host/hardware-configuration.nix"

  if [[ -n $swap_size ]] && ! grep -Fq 'device = "/swapfile"' "$MOUNT_POINT/etc/nixos/$host/hardware-configuration.nix"; then
    sed -i 's|swapDevices = \[ \];|swapDevices = [ { device = "/swapfile"; } ];|' \
      "$MOUNT_POINT/etc/nixos/$host/hardware-configuration.nix"
    grep -Fq 'device = "/swapfile"' "$MOUNT_POINT/etc/nixos/$host/hardware-configuration.nix" ||
      die "Could not add /swapfile to the generated hardware configuration."
  fi

  NIX_CONFIG='extra-experimental-features = nix-command flakes' \
    nixos-install --flake "path:$MOUNT_POINT/etc/nixos#$host"

  read -r -p "Set a password for user [alek] now? [Y/n]: " username
  if [[ ! $username =~ ^[Nn]$ ]]; then
    read -r -p "User name [alek]: " username
    username=${username:-alek}
    nixos-enter --root "$MOUNT_POINT" -c "passwd $username"
  fi

  echo "Installation complete. Reboot after unmounting $MOUNT_POINT."
}

main "$@"
