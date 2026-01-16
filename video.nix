{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };
  # AMD GPU options (commented out)
  # Intel optional packages (commented out)
  # hardware.opengl.extraPackages = with pkgs; [
  #   intel-media-driver
  #   vaapiIntel
  #   intel-compute-runtime
  #   vulkan-loader
  #   vulkan-validation-layers
  #   vulkan-tools
  # ];
  # services.xserver.videoDrivers = [ "amdgpu" ];
  # hardware.opengl.extraPackages = with pkgs; [
  #   amdvlk
  #   vulkan-loader
  #   vulkan-validation-layers
  #   vulkan-tools
  # ];
  # hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
  #   vulkan-loader
  # ];
  # Reminder: test later with `vulkaninfo` once on NixOS.
}
