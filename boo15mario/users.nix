{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alek = {
    isNormalUser = true;
    home = "/home/alek";
    description = "Alek Balaberda";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "kvm" ];
    packages = with pkgs; [
      tmux
      neovim
    ];
  };

  users.extraUsers.alek = {
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };
}
