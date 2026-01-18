# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
      ./hostname.nix
      ./packages.nix
      ./video.nix
       ./system76.nix
       ./access.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" "xfs" ];

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
services.flatpak.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;
#services.desktopManager.plasma6.enable = true;
#services.displayManager.autoLogin.enable = true;
services.displayManager.defaultSession = "gnome";
services.gnome.at-spi2-core.enable = true;
qt = {
  enable = true;
  platformTheme = "gnome";
  style = "breeze";
};
programs.dconf = {
  enable = true;
  profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Breeze-Dark";
          icon-theme = "breeze-dark";
          cursor-theme = "Breeze_Dark";
          color-scheme = "prefer-dark";
        };
        "org/gnome/desktop/sound" = {
          theme-name = "ocean";
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = pkgs.lib.gvariant.mkArray [
            "no-overview@fthx"
            "notification-timeout@chlumskyvaclav.gmail.com"
            "overviewbackground@github.com.orbitcorrection"
          ];
        };
      };
    }
  ];
};
programs.appimage = {
  enable = true;
  binfmt = true;
};
#services.xserver.displayManager.autoLogin.user = "alek";
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
environment = {
  variables = {
    GTK_MODULES = "gail:atk-bridge:canberra-gtk-module";
    ACCESSIBILITY_ENABLED = "1";
  };
  # Helps Electron/Chromium apps behave on Wayland
  sessionVariables = {
    NIXOS_OZONE_WL = "1";
    KDE_COLOR_SCHEME = "BreezeDark";
  };
};
virtualisation.docker.enable = true;
virtualisation.libvirtd.enable = true;
programs.virt-manager.enable = true;
#virtualisation = {
#    podman = {
#      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
#      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
#      defaultNetwork.settings.dns_enabled = true;
#    };
#  };
  # Enable touchpad support (enabled default in most desktopManager).
   services.libinput.enable = true;

  # User accounts live in users.nix.
  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  # Add Nix garbage collection settings
  nix.settings = {
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # System packages live in packages.nix.

#hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # Video config lives in video.nix.
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;
services.locate.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
