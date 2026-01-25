{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    ./access.nix
  ];

  # Packages to include in the ISO
  environment.systemPackages = with pkgs; [
    git
    gedit
    mate.caja
    orca
    lxterminal
    firefox
  ];

  # Enable accessibility features
  services.gnome.at-spi2-core.enable = true;

  # Configure Orca to autostart
  services.xserver.desktopManager.gnome = {
    extraGSettingsOverrides = ''
      [org.gnome.desktop.a11y.applications]
      screen-reader-enabled=true
    '';
  };
  
  # Ensure the installer is available (should be by default in installation-cd-graphical-gnome, but explicit doesn't hurt if custom)
  # The module imported above provides 'calamares' or 'nixos-install' tools typically.
  
  # Optional: nicer console font for accessibility
  console.font = "latarcyrheb-sun32";
}
