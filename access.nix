{ config, pkgs, lib, ... }:

let
  access-launcher = pkgs.rustPlatform.buildRustPackage rec {
    pname = "access-launcher";
    version = "unstable-2025-01-18";

    src = pkgs.fetchFromGitHub {
      owner = "boo15mario";
      repo = "access-launcher";
      rev = "b8e047528c2d91ae6bbc6f31031d1e67908d8f6c";
      # TODO: Replace with correct hash after first build failure
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    # TODO: Replace with correct hash after first build failure
    cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.gtk4 ];
  };

  universal-startup-manager = pkgs.rustPlatform.buildRustPackage rec {
    pname = "universal-startup-manager";
    version = "unstable-2025-01-18";

    src = pkgs.fetchFromGitHub {
      owner = "boo15mario";
      repo = "universal-startup-manager";
      rev = "a1f030e321b4dff38d8e14e3e200d81a223a9315";
      # TODO: Replace with correct hash after first build failure
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    # TODO: Replace with correct hash after first build failure
    cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.gtk4 ];
  };
in
{
  environment.systemPackages = [
    access-launcher
    universal-startup-manager
  ];
}
