{ config, pkgs, lib, ... }:

{
    nixpkgs.overlays = [
    (final: prev:
      let
        accessPkgs = import (builtins.fetchTarball {
          url = "https://github.com/boo15mario/access-nix/archive/ef9d1ac4c5dee432d1ac00f4071877b0bbb3a9d3.tar.gz";
          sha256 = "0wndhngh6mbhv7i0m4nxihcdnrjyfa4257wqxflnfbdi44qbsmj9";
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
