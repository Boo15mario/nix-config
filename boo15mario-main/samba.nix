{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "${config.networking.hostName}";
        "netbios name" = "${config.networking.hostName}";
        "security" = "user";
        # "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        # "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "private" = {
        "path" = "/home/alek/Share";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "alek";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "alek";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
