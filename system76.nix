{ config, pkgs, ... }:

{
  # System76
  hardware.system76.enableAll = true;
  services.power-profiles-daemon.enable = false;
}
