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
      hash = "sha256-ScpC6uOZ06UTzyI8Zkp1qsPnG2zllklM5KefkbJdwiA=";
    };

    # TODO: Replace with correct hash after first build failure
    cargoHash = "sha256-Yri+MWl28/N36MPweGQBOBZSmyC3L89anXe5kwITIxY=";

    nativeBuildInputs = [ pkgs.pkg-config pkgs.copyDesktopItems ];
    buildInputs = [ pkgs.gtk4 ];

    postInstall = ''
      mkdir -p $out/share/icons/hicolor/512x512/apps
      if [ -f assets/icon.png ]; then
        install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/${pname}.png
      elif [ -f icon.png ]; then
        install -Dm644 icon.png $out/share/icons/hicolor/512x512/apps/${pname}.png
      fi
    '';

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "access-launcher";
        desktopName = "Access Launcher";
        exec = "access-launcher";
        icon = "access-launcher";
        categories = [ "Utility" ];
      })
    ];
  };

  universal-startup-manager = pkgs.rustPlatform.buildRustPackage rec {
    pname = "universal-startup-manager";
    version = "unstable-2025-01-18";

    src = pkgs.fetchFromGitHub {
      owner = "boo15mario";
      repo = "universal-startup-manager";
      rev = "a1f030e321b4dff38d8e14e3e200d81a223a9315";
      # TODO: Replace with correct hash after first build failure
      hash = "sha256-uQ0VorRU02af5cxMODRWusokqWG9JbwTNstlFv3RIJ4=";
    };

    # TODO: Replace with correct hash after first build failure
    cargoHash = "sha256-Dr27mzPiSmkeTnmHTDgDnkmThq+AkZ6KFHoFf2645uk=";

    nativeBuildInputs = [ pkgs.pkg-config pkgs.copyDesktopItems ];
    buildInputs = [ pkgs.gtk4 ];

    postInstall = ''
      mkdir -p $out/share/icons/hicolor/512x512/apps
      if [ -f assets/icon.png ]; then
        install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/${pname}.png
      elif [ -f icon.png ]; then
        install -Dm644 icon.png $out/share/icons/hicolor/512x512/apps/${pname}.png
      fi
    '';

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "universal-startup-manager";
        desktopName = "Universal Startup Manager";
        exec = "universal-startup-manager";
        icon = "universal-startup-manager";
        categories = [ "Utility" ];
      })
    ];
  };
in
{
  environment.systemPackages = [
    access-launcher
    universal-startup-manager
  ];


}
