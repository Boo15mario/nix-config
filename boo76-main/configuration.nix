{ lib, ... }:

{
  # Reuse boo76's machine-specific hardware and desktop configuration.
  imports = [ ../boo76/configuration.nix ];

  # The flake supplies the hostname for this profile.
  networking.hostName = lib.mkForce "boo76-main";
}
