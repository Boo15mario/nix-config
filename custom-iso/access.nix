{ config, pkgs, lib, ... }:

{
    nixpkgs.overlays = [
    (final: prev:
      let
        accessPkgs = import (builtins.fetchTarball {
          url = "https://github.com/boo15mario/access-nix/archive/5794f74202dbf277cef4dde3d59f2a57b10e06f9.tar.gz";
          sha256 = "0nj801maiijxqn35pqmnaffr8iqc39ick6z6440hipdb1bxci7pg";
        }) {
          pkgs = prev;
        };
      in
      {
        inherit (accessPkgs) access-launcher universal-startup-manager waytray gtkmud access-grub access-os-artwork access-os-plymouth-theme;
      })
  ];

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
