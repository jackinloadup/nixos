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
  debug = false;
in {
  imports = [
    ./hardware-configuration.nix
    ./usb-switch-monitor-input.nix
    #./rename-pipewire-sinks.nix # isn't working and caused build error on
    #unstable eventually
    ./monitor-setup.nix
    ./switch-desk.nix
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

    hardware.bluetooth.enable = true;
    hardware.logitech.wireless.enable = mkDefault true;
    hardware.logitech.wireless.enableGraphical = mkDefault true;

    services.bpftune.enable = true;
    services.hardware.bolt.enable = true;

    powerManagement.cpuFreqGovernor = mkForce "performance";

    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

    programs.simula.enable = false;
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
    services.media-services.enable = true;

    #services.displayManager.enable = true; # enable systemd’s display-manager service
    #services.displayManager.sddm.enable = true;
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "lriutzel";
    services.displayManager.defaultSession = "hyprland";


    # ollama.home.lucasr.com in mirotik static dns
    services.ollama = {
      enable = true;
      rocmOverrideGfx = "11.0.0"; ## rdna 3 11.0.0
      acceleration = "rocm";
      openFirewall = true;
      host = "ollama.home.lucasr.com";
      home = "/var/lib/private/ollama";
      user = "ollama";
      loadModels = [
        "deepseek-r1"
        "llama3.2:1b"
        "codellama"
        "gemma2:9b"
        #"gemma2:27b" # too big
        "mistral"
        "moondream"
        "starling-lm"
        "solar"
        "llava"
        "llama2-uncensored"
        "phi4"
        "phi3"
      ];

      package = pkgs.unstable.ollama;

      environmentVariables = {
        OLLAMA_ORIGINS = "*";
      };
    };

    # ollama.home.lucasr.com in mirotik static dns
    services.open-webui = {
      enable = true;
      openFirewall = true;
      port = 11112;
      stateDir = "/var/lib/private/open-webui";
      host = "chat.lucasr.com";
      environment = {
        # PYDANTIC_SKIP_VALIDATING_CORE_SCHEMAS = "True";
        OLLAMA_BASE_URL = "http://ollama.home.lucasr.com:${toString config.services.ollama.port}";
        ENABLE_OLLAMA_API = "true";
        DEFAULT_USER_ROLE = "user";
        WEBUI_AUTH = "False";
        #WEBUI_AUTH_TRUSTED_EMAIL_HEADER = "X-Webauth-Email";
        #WEBUI_AUTH_TRUSTED_NAME_HEADER = "X-Webauth-Name";
        ENABLE_OAUTH_SIGNUP = "false";
        ENABLE_SIGNUP = "false";
        WEBUI_URL = "https://chat.lucasr.com";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "false";

        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };

    #services.vaultwarden = {
    #  enable = false;
    #  environmentFile = config.age.secrets.vaultwarden-env.path;
    #  #backupDir = "/var/lib/vw-backup";

    #  config = {
    #    DOMAIN = "https://bw.9000.dev";
    #    SIGNUPS_ALLOWED = "false";
    #    PASSWORD_HINTS_ALLOWED = "false";
    #    ROCKET_ADDRESS = "127.0.0.1";
    #    ROCKET_PORT = 8222;
    #    PASSWORD_ITERATIONS = 600000;
    #  };
    #};

    # Login Manager
    services.xserver.displayManager.gdm.enable = true;
    #services.xserver.enable = true;
    #services.xserver.displayManager.lightdm.enable = true;
    security.polkit.enable = true;

    #services.desktopManager.plasma6.enable = true;
    #services.xserver.desktopManager.plasma5.enable = true;
    #programs.ssh.askPassword = mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
    #programs.ssh.askPassword = mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    ## xdg-desktop-portal-gnome 44 causes delays in non-GNOME desktops
    ##     https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.windowManager.i3.enable = true;

    system.autoUpgrade = {
      enable = true;
      flake = flake.self.outPath;
      flags = [
        "--update-input"
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
      storageServer.backup = true;

      vpn.server.endpoint = "home.lucasr.com:51820";
      vpn.client.enable = true;
      vpn.client.ip = "10.100.0.11/24";
    };
    #nix.settings.max-jobs = lib.mkDefault 16;

    nixpkgs.overlays = [
      flake.inputs.nur.overlays.default
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

    networking.hostName = "reg";
    networking.bridges.br0.interfaces = ["eno1"];
    networking.interfaces.br0.useDHCP = true;
    networking.enableIPv6 = false;
    virtualisation.libvirtd.allowedBridges = ["br0"];

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

        services.satellite-images.enable = false;
        services.satellite-images.generateTimelapse = false;

        programs.wpaperd = {
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
