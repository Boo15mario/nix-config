{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nano
    wget
    jq
    curl
    aria2
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
    nodejs
    texliveFull
    tesseract
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
