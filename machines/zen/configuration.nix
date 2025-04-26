{
  self,
  flake,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkForce mkDefault getExe;
  settings = import ../../settings;
  debug = true;
in {
  imports = [
    #./control-monitor-backlight.nix
    ./hardware-configuration.nix
    #./rename-pipewire-sinks.nix # isn't working and caused build error on
    #unstable eventually
    #./monitor-setup.nix
  ];

  config = {
    environment.systemPackages = [ ];

    boot.crashDump.enable = false; # Causes kernel build

    boot.initrd.network.enable = true;
    boot.initrd.systemd.network.enable = true;

    boot.initrd.verbose = debug;
    boot.plymouth.enable = !debug;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true; # already default
    hardware.logitech.wireless.enable = mkDefault true;
    hardware.logitech.wireless.enableGraphical = mkDefault true;

    services.hardware.bolt.enable = true;

    powerManagement.cpuFreqGovernor = mkForce "performance";

    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

    programs.simula.enable = false;
    programs.sway.enable = false;

    nixpkgs.hostPlatform = "x86_64-linux";

    #networking.firewall.allowedTCPPorts = [ 19999 ]; # netdata port;
    #services.netdata.enable = true;

    services.flatpak.enable = true;
    services.pipewire.enable = true;


    #services.displayManager.enable = true; # enable systemd’s display-manager service
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "criutzel";
    services.displayManager.defaultSession = "gnome";
    # Login Manager
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.enable = true;
    #services.xserver.displayManager.lightdm.enable = true;
    security.polkit.enable = true;


    ## xdg-desktop-portal-gnome 44 causes delays in non-GNOME desktops
    ##     https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
    services.xserver.desktopManager.gnome.enable = true;

    home-manager.users.criutzel = {
      imports = [
        #../../users/criutzel/impermanence.nix
      ];
    };
    environment.persistence = {
      "/persist" = {
        hideMounts = true;
        directories = [
          "/home/criutzel"
        ];
      };
    };

    #system.autoUpgrade = {
    #  enable = true;
    #  flake = flake.self.outPath;
    #  flags = [
    #    "--update-input"
    #    "nixpkgs"
    #    "-L"
    #  ];
    #  dates = "09:00";
    #  randomizedDelaySec = "45min";
    #};

    xdg.portal.enable = true;
    environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
    xdg.portal.config = {

    };

    environment.profileRelativeEnvVars = {
      QT_PLUGIN_PATH = [
      #  ("/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix)
        ("/run/current-system/sw/" + pkgs.qt6.qtbase.qtPluginPrefix)
      ];

      QML2_IMPORT_PATH = [
       # ("/run/current-system/sw/" + pkgs.qt5.qtbase.qtqmlprefix)
        ("/run/current-system/sw/" + pkgs.qt6.qtbase.qtPluginPrefix)
      ];
      XDG_DATA_DIRS = ["/run/current-system/sw/share"];
    };

    environment.variables = {
      QT_QPA_PLATFORM = "wayland;xcb";
    };

    machine = {
      users = [
        "lriutzel"
        "criutzel"
      ];
      tui = true;
      sizeTarget = 3;
      gaming = true;
      impermanence = true;
      lowLevelXF86keys.enable = true;
    };

    gumdrop = {
      printerScanner = true;
      storageServer.enable = true;
      storageServer.media = true;
      storageServer.roms = true;
      storageServer.family = true;

      vpn.server.endpoint = "vpn.lucasr.com:51820";
      vpn.client.enable = true;
      vpn.client.ip = "10.100.0.6/24";
    };

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "zen";
    networking.enableIPv6 = false;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?

    home-manager.sharedModules = [
      {
        #dconf.settings."org/gnome/desktop/interface".show-battery-percentage = true;
      }
      {
        wayland.windowManager.sway.enable = config.programs.sway.enable;
        wayland.windowManager.hyprland.enable = config.programs.hyprland.enable;
      }
      {
        xdg.desktopEntries = {
          #monitor-light = {
          #  name = "Monitor Light";
          #  exec = "${getExe flake.inputs.scripts.packages.x86_64-linux.monitor-light}";
          #  terminal = false;
          #  categories = [
          #    "Utility"
          #  ];
          #};
          #monitor-dark = {
          #  name = "Monitor Dark";
          #  exec = "${getExe flake.inputs.scripts.packages.x86_64-linux.monitor-dark}";
          #  terminal = false;
          #  categories = [
          #    "Utility"
          #  ];
          #};
        };
      }
    ];
  };
}
