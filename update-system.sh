#!/usr/bin/env bash

set -Eeuo pipefail

script_name="${0##*/}"
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
requested_action="menu"
host_override=""

print_help() {
  cat <<EOF
Usage: ${script_name} [OPTIONS]

Update this repository's flake inputs and optionally rebuild a NixOS system.
Without an action option, the script presents an interactive menu.

Options:
  -h, --help            Show this help text and exit.
  -H, --host PROFILE    Override the hostname used as the flake profile.
  -a, --action ACTION   Select menu, flake, switch, or boot.
      --flake-only      Update flake inputs without rebuilding.
      --switch          Update, rebuild, and activate the system now.
      --boot            Update and install the system for the next boot.

Environment overrides:
  NIXOS_HOST=PROFILE    Override the detected hostname. --host takes priority.

Examples:
  ./${script_name}
      Open the interactive menu using the current hostname.

  ./${script_name} --flake-only
      Update flake.lock without rebuilding the system.

  ./${script_name} --host boo76 --switch
      Update and switch the boo76 profile immediately.

  ./${script_name} --host boo76-main --boot
      Update boo76-main and make it the default for the next boot.

  NIXOS_HOST=boo76-main ./${script_name} --action switch
      Override the detected profile through the environment.

Rebuild actions stream terminal output and Nix build logs.
Repository: ${repo_dir}
EOF
}

fail() {
  echo "$*" >&2
  exit 2
}

set_action() {
  local new_action="$1"

  case "$new_action" in
    menu|flake|switch|boot)
      ;;
    flake-only)
      new_action="flake"
      ;;
    *)
      fail "Unknown action '${new_action}'. Use menu, flake, switch, or boot."
      ;;
  esac

  if [[ "$requested_action" != "menu" && "$requested_action" != "$new_action" ]]; then
    fail "Conflicting actions: '${requested_action}' and '${new_action}'."
  fi
  requested_action="$new_action"
}

while (( $# > 0 )); do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    -H|--host)
      (( $# >= 2 )) || fail "$1 requires a profile name."
      [[ -n "$2" ]] || fail "$1 requires a non-empty profile name."
      host_override="$2"
      shift 2
      ;;
    --host=*)
      host_override="${1#*=}"
      [[ -n "$host_override" ]] || fail "--host requires a non-empty profile name."
      shift
      ;;
    -a|--action)
      (( $# >= 2 )) || fail "$1 requires an action."
      set_action "$2"
      shift 2
      ;;
    --action=*)
      set_action "${1#*=}"
      shift
      ;;
    --flake-only)
      set_action flake
      shift
      ;;
    --switch)
      set_action switch
      shift
      ;;
    --boot)
      set_action boot
      shift
      ;;
    --)
      shift
      (( $# == 0 )) || fail "Unexpected argument: $1"
      ;;
    *)
      fail "Unknown option: $1. Use --help for usage."
      ;;
  esac
done

if (( EUID == 0 )); then
  echo "Run this script as your normal user. It will request sudo for rebuilds." >&2
  exit 1
fi

for required_command in nix nixos-rebuild sudo hostname; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "Required command not found: $required_command" >&2
    exit 1
  fi
done

flake_ref="path:${repo_dir}"
host_name="${host_override:-${NIXOS_HOST:-$(hostname -s)}}"

if [[ ! "$host_name" =~ ^[A-Za-z0-9._-]+$ ]]; then
  fail "Invalid host profile name: '${host_name}'."
fi

update_flake() {
  echo
  echo "Updating flake inputs in ${repo_dir}..."
  (
    cd "$repo_dir"
    nix flake update
  )
}

validate_host_profile() {
  local configured_host

  if ! configured_host="$(
    nix eval \
      --raw \
      "${flake_ref}#nixosConfigurations.${host_name}.config.networking.hostName" \
      2>/dev/null
  )"; then
    echo "No working NixOS flake profile was found for '${host_name}'." >&2
    echo "Set NIXOS_HOST to a valid profile and run the script again." >&2
    echo "Example: NIXOS_HOST=boo76-main ./update-system.sh" >&2
    echo "Available profile names:" >&2
    nix eval \
      --json \
      "${flake_ref}#nixosConfigurations" \
      --apply 'profiles: builtins.attrNames profiles' >&2 || true
    exit 1
  fi

  if [[ "$configured_host" != "$host_name" ]]; then
    echo "Profile '${host_name}' evaluates to hostname '${configured_host}'." >&2
    exit 1
  fi
}

rebuild_system() {
  local action="$1"

  validate_host_profile
  echo
  echo "Running nixos-rebuild ${action} for ${host_name}..."
  echo "Nix build logs will be streamed to this terminal."
  sudo nixos-rebuild \
    "$action" \
    --print-build-logs \
    --flake "${flake_ref}#${host_name}"
}

show_menu() {
  local choice

  echo "NixOS system updater"
  echo "Repository: ${repo_dir}"
  echo "Host profile: ${host_name}"
  echo
  echo "1) Update flake inputs only"
  echo "2) Update flake inputs and switch the running system (live build logs)"
  echo "3) Update flake inputs and install the system for the next boot (live build logs)"
  echo "q) Quit"
  echo
  read -r -p "Choose an option [1-3, q]: " choice

  case "$choice" in
    1)
      requested_action="flake"
      ;;
    2)
      requested_action="switch"
      ;;
    3)
      requested_action="boot"
      ;;
    q|Q)
      echo "No changes made."
      exit 0
      ;;
    *)
      fail "Invalid selection: ${choice}"
      ;;
  esac
}

if [[ "$requested_action" == "menu" ]]; then
  show_menu
else
  echo "NixOS system updater"
  echo "Repository: ${repo_dir}"
  echo "Host profile: ${host_name}"
  echo "Requested action: ${requested_action}"
fi

case "$requested_action" in
  flake)
    update_flake
    echo
    echo "Flake inputs updated. The running and boot systems were not changed."
    ;;
  switch)
    update_flake
    rebuild_system switch
    echo
    echo "Update complete. The new configuration is running and set for boot."
    ;;
  boot)
    update_flake
    rebuild_system boot
    echo
    echo "Update complete. Reboot to start the new configuration."
    ;;
  *)
    fail "Internal error: unsupported action '${requested_action}'."
    ;;
esac
