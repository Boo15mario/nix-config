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
    ruby
    go
    ghc
    cabal-install
    jdk8
    jdk11
    jdk17
    jdk21
    gnumake
    gcc
    rustc
    cargo
    unstable.nodejs
    gh
    git
    libsecret
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
