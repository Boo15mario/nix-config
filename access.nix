{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: import (builtins.fetchTarball "https://github.com/boo15mario/access-nix/archive/main.tar.gz") {
      pkgs = final;
    })
  ];

  environment.systemPackages = [
    pkgs.access-launcher
    pkgs.universal-startup-manager
  ];


}
