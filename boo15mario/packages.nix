{ config, pkgs, ... }:
let
  unstable = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz") { config = config.nixpkgs.config; };
in
{
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    python3
    gnumake
    gcc
    rustc
    cargo
    unstable.nodejs
    gh
    git
    fastfetch
    htop
    speedtest-cli
    
    # Networking/Sysadmin
    dnsutils
    iputils
    usbutils
    pciutils
    tailscale
    
    # Samba related (service in samba.nix)
    samba
    cifs-utils
  ];
}
