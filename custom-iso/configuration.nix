{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    ./access.nix
    ./audio.nix
  ];

  # Custom ISO boot settings
  isoImage.isoName = "access-nix-custom.iso";
  isoImage.volumeId = "ACCESS_NIX";
  isoImage.grubConfig = ''
    set menu_color_normal=white/black
    set menu_color_highlight=white/red
  '';
  isoImage.syslinuxTheme = ''
    MENU TITLE Access-Nix Custom Installer
    MENU RESOLUTION 800 600
    MENU COLOR BORDER   30;44 #00000000 #00000000 none
    MENU COLOR SCREEN   37;40 #FF000000 #FF000000 none
    MENU COLOR TITLE    1;36;44 #FFFFFFFF #00000000 none
    MENU COLOR SEL      7;37;40 #FFFFFFFF #FFFF0000 all
    MENU COLOR UNSEL    37;44 #FFFFFFFF #00000000 none
    MENU COLOR HELP     37;40 #FFFFFFFF #00000000 none
    MENU COLOR TIMEOUT  1;37;40 #FFFFFFFF #00000000 none
  '';

  # Packages to include in the ISO
  environment.systemPackages = with pkgs; [
    git
    jq
    aria2
    gedit
    mate.caja
    orca
    lxterminal
    firefox
  ];

  programs.nix-ld.enable = true;

  # Enable accessibility features
  services.gnome.at-spi2-core.enable = true;

  # Configure Orca to autostart
  services.xserver.desktopManager.gnome = {
    extraGSettingsOverrides = ''
      [org.gnome.desktop.a11y.applications]
      screen-reader-enabled=true
    '';
  };

  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
  
  # Ensure the installer is available (should be by default in installation-cd-graphical-gnome, but explicit doesn't hurt if custom)
  # The module imported above provides 'calamares' or 'nixos-install' tools typically.
  
  # Optional: nicer console font for accessibility
  console.font = "latarcyrheb-sun32";
}
