{ config, pkgs, ... }:

{
  # System76
  hardware.system76.enableAll = true;
  services.power-profiles-daemon.enable = false;
  environment.systemPackages = with pkgs; [
    system76-firmware
    system76-keyboard-configurator
    system76-power
    system76-scheduler
    system76-wallpapers
  ];
}
