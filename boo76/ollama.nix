{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };

  # Add the ollama CLI to system packages
  environment.systemPackages = [
    pkgs.ollama-vulkan
  ];
}
