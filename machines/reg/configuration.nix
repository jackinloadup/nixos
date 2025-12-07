{
  flake,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkForce mkDefault getExe;
  debug = false;
in {
  imports = [
    ./hardware-configuration.nix
    ./usb-switch-monitor-input.nix
    #./rename-pipewire-sinks.nix # isn't working and caused build error on
    #unstable eventually
    ./monitor-setup.nix
    ./switch-desk.nix
    ./aichat.nix
    flake.self.nixosModules.work
  ];

  config = {

    #boot.kernelPackages = pkgs.linuxPackages_cachyos;
    environment.systemPackages = [
      #pkgs.scx
      pkgs.cpufrequtils
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
    #boot.initrd.network.tor.enable = true;
    #boot.initrd.network.ntpd.enable = true;
    #boot.initrd.network.ntpd.address = "5.78.71.97"; # ip of 0.north-america.pool.ntp.org

    boot.initrd.verbose = debug;
    boot.plymouth.enable = !debug;
    boot.plymouth.themePackages = mkForce [ pkgs.catppuccin-plymouth ];
    boot.plymouth.theme = mkForce "catppuccin-macchiato";

    # dragon, doesn't look too good in tty only works in pty
    environment.etc.issue.source = mkForce ./issue-banner;

    hardware.bluetooth.enable = false;
    hardware.logitech.wireless.enable = mkDefault true;
    hardware.logitech.wireless.enableGraphical = mkDefault true;

    services.bpftune.enable = true;
    services.hardware.bolt.enable = true; # thunderbolt

    powerManagement.cpuFreqGovernor = mkForce "performance";

    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;
    programs.niri.enable = true;
    programs.sway.enable = false;

    #services.mullvad-vpn.enable = true;
    #services.mullvad-vpn.package = pkgs.mullvad-vpn; # install version with GUI

    # required for mullvad
    #services.resolved = {
    #  enable = true;
    #  dnssec = "true";
    #  domains = [ "~." ];
    #  fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    #  dnsovertls = "true";
    #};


    #nixpkgs.config.rocmSupport = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    #services.hydra.enable = true;

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

    #services.snapserver = {
    #  enable = true;
    #  openFirewall = true;
    #};

    #networking.firewall.allowedTCPPorts = [ 19999 ]; # netdata port;
    #services.netdata.enable = true;

    services.flatpak.enable = true;
    services.pipewire.enable = true;
    services.sunshine.enable = true;

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
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "lriutzel";
    services.displayManager.defaultSession = "niri";

    # Login Manager
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.xserver.windowManager.i3.enable = false;

    #services.xserver.enable = true;
    #services.xserver.displayManager.lightdm.enable = true;
    security.polkit.enable = true;

    #services.desktopManager.plasma6.enable = true;
    #services.xserver.desktopManager.plasma5.enable = true;
    #programs.ssh.askPassword = mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
    #programs.ssh.askPassword = mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";


    system.autoUpgrade = {
      enable = false; # secrets repo is limiting factor atm
      flake = flake.self.outPath;
      flags = [
        "--update-input" # warning: '--update-input' is a deprecated alias for 'flake update' and will be removed in a future version.
        "nixpkgs"
        "-L"
      ];
      dates = "21:15";
      randomizedDelaySec = "45min";
    };

    systemd.services.domainname = {
      startLimitIntervalSec = 30;
      startLimitBurst = 5;
    };

    xdg.portal.enable = true;
    environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

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
      storageServer.backup = true;

      vpn.server.endpoint = "vpn.lucasr.com:51820";
      vpn.client.enable = true;
      vpn.client.ip = "10.100.0.11/24";
    };

    networking.hostName = "reg";
    networking.bridges.br0.interfaces = ["eno1"];
    networking.interfaces.br0.useDHCP = true;
    networking.enableIPv6 = false;
    virtualisation.libvirtd.allowedBridges = ["br0"];

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
        wayland.windowManager.sway.enable = config.programs.sway.enable;
        wayland.windowManager.hyprland.enable = config.programs.hyprland.enable;
        programs.niri.enable = true;

        services.satellite-images.enable = false;
        services.satellite-images.generateTimelapse = false;

        services.wpaperd = {
          enable = true;
          settings.default = {
            #path = "~/.cache/satellite-images";
            #sorting = "ascending";
            #transition-time = "1000";
            #duration = "42ms"; # 24fps?
            #mode = "center";
            path = "~/Pictures/Wallpapers";
            sorting = "random";
            duration = "5m";
          };
        };
      }
      {
        xdg.desktopEntries = {
          switch-to-savi-audio = {
            name = "Switch Audio to Savi";
            exec = "${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.usb-Plantronics_Savi_8220_008E6839CE254D13A0969E205B788648-01.analog-stereo";
            terminal = false;
            categories = [
              "Utility"
            ];
          };
          switch-to-desktop-audio = {
            name = "Switch Audio to Desktop";
            exec = "${pkgs.pulseaudio}/bin/pactl set-default-sink alsa_output.pci-0000_1f_00.3.analog-stereo";
            terminal = false;
            categories = [
              "Utility"
            ];
          };
          monitor-light = {
            name = "Monitor Light";
            exec = "${getExe flake.inputs.scripts.packages.x86_64-linux.monitor-light}";
            terminal = false;
            categories = [
              "Utility"
            ];
          };
          monitor-dark = {
            name = "Monitor Dark";
            exec = "${getExe flake.inputs.scripts.packages.x86_64-linux.monitor-dark}";
            terminal = false;
            categories = [
              "Utility"
            ];
          };
        };
      }
    ];
  };
}
