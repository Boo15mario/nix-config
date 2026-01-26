{ config, pkgs, ... }:

{
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    nodejs
    gh
    git
    fastfetch
    htop
    speedtest-cli
    
    # Networking/Sysadmin
    dnsutils
    iputils
    usbutils
    pciutils
    tailscale
    
    # Samba related (service in samba.nix)
    samba
    cifs-utils
  ];
}
