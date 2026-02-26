{ config, pkgs, lib, ... }:

{
  # The overlay for access-nix is now handled in the root flake.nix

  environment.systemPackages = [
    pkgs.access-launcher
    pkgs.universal-startup-manager
    pkgs.waytray
    pkgs.gtkmud
    pkgs.emacs-pgtk
    pkgs.access-os-artwork
  ];

  services.emacs.enable = true;
  services.emacs.package = pkgs.emacs-pgtk;

}
