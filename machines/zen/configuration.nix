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
    ./change-logitec-suspend.nix
    #./control-monitor-backlight.nix
    ./hardware-configuration.nix
    #./rename-pipewire-sinks.nix # isn't working and caused build error on
    #unstable eventually
    #./monitor-setup.nix
  ];

  config = {

    #boot.kernelPackages = pkgs.linuxPackages_cachyos;
    environment.systemPackages = [
      #pkgs.scx
      #pkgs.cpufrequtils
    ];

    # Not being used. disabling due to other issues
    #boot.binfmt.emulatedSystems = [
    #  "wasm32-wasi"
    #  #"i686-embedded"
    #  "x86_64-windows"
    #  "aarch64-linux"
    #];
    boot.crashDump.enable = false; # Causes kernel build

    boot.initrd.network.enable = true;
    boot.initrd.systemd.network.enable = true;

    boot.initrd.verbose = debug;
    boot.plymouth.enable = !debug;

    hardware.bluetooth.enable = true;
    hardware.logitech.wireless.enable = mkDefault true;
    hardware.logitech.wireless.enableGraphical = mkDefault true;

    services.hardware.bolt.enable = true;

    powerManagement.cpuFreqGovernor = mkForce "performance";

    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

    programs.simula.enable = false;
    programs.sway.enable = true;

    #nixpkgs.config.rocmSupport = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    #services.hydra.enable = true;
    services.jellyfin = {
      enable = false;
      openFirewall = true;
    };

    #services.k3s.enable = false;
    #services.k3s.role = "server";
    #services.k3s.clusterInit = true;

    services.kubo = {
      enable = false;
      startWhenNeeded = true;
      autoMount = true;
      enableGC = true;
      settings = {
        Datastore = {
          StorageMax = "100GB";
        };
        Discovery = {
          MDNS.Enabled = true;
         #Swarm.AddrFilters = null;
        };
        Addresses.API = "/ip4/127.0.0.1/tcp/5001";
        Experimental.FilestoreEnabled = true;
        Experimental.Libp2pStreamMounting = true;
        Reprovider.Interval = "1h";
        Swarm.ConnMgr.GracePeriod = "60s";
        Swarm.RelayClient.Enabled = true;
      };
      extraFlags = [ "--enable-pubsub-experiment" ];
    };

    #networking.firewall.allowedTCPPorts = [ 19999 ]; # netdata port;
    #services.netdata.enable = true;

    services.flatpak.enable = true;
    services.pipewire.enable = true;

    #services.rtl_433 = {
    #  enable = false;
    #  package = pkgs.rtl_433-dev;
    #  configText = ''
    #    output json
    #    output mqtt://mqtt.home.lucasr.com,user=mosquitto,pass=mosquitto,retain=0,events=rtl_433[/model][/id]
    #    report_meta time:utc
    #    frequency 915M
    #    frequency 433.92M
    #    convert si
    #    hop_interval 60
    #    gain 0
    #  '';
    #};

    #services.displayManager.enable = true; # enable systemd’s display-manager service
    #services.displayManager.sddm.enable = true;
    #services.displayManager.sddm.enableHidpi = false;
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "criutzel";
    services.xserver.displayManager.defaultSession = "gnome";
    # Login Manager
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.enable = true;
    #services.xserver.displayManager.lightdm.enable = true;
    security.polkit.enable = true;

    #services.desktopManager.plasma6.enable = true;
    #services.xserver.desktopManager.plasma5.enable = true;
    #programs.ssh.askPassword = mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
    #programs.ssh.askPassword = mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    ## xdg-desktop-portal-gnome 44 causes delays in non-GNOME desktops
    ##     https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
    services.xserver.desktopManager.gnome.enable = true;
    #services.xserver.windowManager.i3.enable = true;
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
      storageServer.home = false;
    };
    nix.settings.max-jobs = lib.mkDefault 16;

    nixpkgs.overlays = [
      flake.inputs.nur.overlay
      flake.inputs.self.overlays.default
      flake.inputs.self.overlays.kodi-wayland
      # Math libraries for AMD CPUs
      # causes rebuilds, ran into a lot of failed python tests
      #(self: super:
      #  {
      #    blas = super.blas.override {
      #      blasProvider = self.amd-blis;
      #    };
      #
      #    lapack = super.lapack.override {
      #      lapackProvider = self.amd-libflame;
      #    };
      #  }
      #)
    ];

    networking.hostName = "zen";
    #networking.bridges.br0.interfaces = ["eno1"];
    #networking.interfaces.br0.useDHCP = true;
    networking.enableIPv6 = false;
    #virtualisation.libvirtd.allowedBridges = ["br0"];

    #networking.firewall.allowedTCPPorts = [ 8000 ]; # What is port 8000 for?
    #networking.firewall.allowedUDPPorts = [ 8000 ];

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
