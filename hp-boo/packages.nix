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
