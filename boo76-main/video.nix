{ config, pkgs, ... }:

{
  # The NVIDIA PRIME module adds the AMD X driver using the bus ID below.
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      # AMD is the primary display GPU; use `nvidia-offload <program>` when
      # an application should render on the NVIDIA GPU.
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1@0:0:0";
      amdgpuBusId = "PCI:13@0:0:0";
    };
  };
}
