{ config, pkgs, ... }:
let
  unstable = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz") { config = config.nixpkgs.config; };
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    python3
    ruby
    go
    ghc
    cabal-install
    jdk8
    jdk11
    jdk17
    jdk21
    jdk23
    gnumake
    gcc
    rustc
    cargo
    unstable.nodejs
    gh
    git
    gnome-extension-manager
    gnomeExtensions."no-overview"
    gnomeExtensions."notification-timeout"
    gnomeExtensions."overview-background"
    gnomeExtensions.bing-wallpaper-changer
    orca
      speechd
    playerctl
      quickemu
    ntfs3g
    libcanberra-gtk3
    corefonts
    vista-fonts
    kdePackages."breeze-gtk"
    kdePackages.breeze-icons
    kdePackages.breeze
    kdePackages.ocean-sound-theme
    sox
    fastfetch
    htop
    speedtest-cli
    wineWowPackages.stable
    winetricks
    lutris
    bottles
    gdm-settings
    # Printing and Samba
    hplip
    system-config-printer
    gutenprint
    cups-filters
    samba
    cifs-utils
    tailscale
  ];


}
