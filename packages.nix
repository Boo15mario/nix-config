{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    nodejs
    gh
    git
    gnome-extension-manager
    gnomeExtensions."no-overview"
    gnomeExtensions."notification-timeout"
    gnomeExtensions."overview-background"
    codex
    gemini-cli
    ntfs3g
    libcanberra-gtk3
    corefonts
    vista-fonts
    kdePackages."breeze-gtk"
    kdePackages.breeze-icons
    kdePackages.breeze
    kdePackages.ocean-sound-theme
  ];
}
