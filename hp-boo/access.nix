{ config, pkgs, lib, ... }:

{
    nixpkgs.overlays = [
    (final: prev:
      let
        accessPkgs = import (builtins.fetchTarball "https://github.com/boo15mario/access-nix/archive/main.tar.gz") {
          pkgs = prev;
        };
      in
      {
        inherit (accessPkgs) access-launcher universal-startup-manager waytray gtkmud access-grub;
      })
  ];

  environment.systemPackages = [
    pkgs.access-launcher
    pkgs.universal-startup-manager
    pkgs.waytray
    pkgs.gtkmud
    pkgs.emacs-pgtk
    pkgs.espeakup
  ];

  services.emacs.enable = true;
  services.emacs.package = pkgs.emacs-pgtk;

}
