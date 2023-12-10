{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkOption mkIf mkDefault mkOverride optionals elem;
  inherit (lib.types) listOf enum;

  cfg = config.machine;
  ifTui = cfg.sizeTarget > 0;
  ifGraphical = cfg.sizeTarget > 1;
  ifFull = cfg.sizeTarget > 2;
  settings = import ./settings.nix;
  username = "lriutzel";
  fullSystems = ["reg" "riko"];
  hostname = config.networking.hostName;
  isFullSystem = elem hostname fullSystems;
  userEnabled = elem username config.machine.users;
in {

  imports = [
    flake.inputs.nix-ld.nixosModules.nix-ld
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = listOf (enum [username]);
  };

  config = mkIf userEnabled {
    nix.settings.trusted-users = [username];

    users.users."${username}" = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "audio"
        "video"
        "input"
        "networkmanager"
        "wireshark"
        "dialout" # needed for flashing serial devices ttyUSB0
        "ipfs"
        #dip netdev plugdev
        # cdrom floppy
      ];
    };

    programs.adb.enable = isFullSystem;
    programs.command-not-found.enable = isFullSystem;
    programs.chirp.enable = isFullSystem;
    programs.chromium.enable = isFullSystem;
    programs.sniffnet.enable = isFullSystem;
    programs.nix-ld.enable = isFullSystem;
    #programs.nix-ld.dev.enable = isFullSystem; # dev = using flake vs nixpkgs
    programs.nix-ld.libraries = [
      pkgs.SDL2
      pkgs.SDL2_image
      pkgs.SDL2_sound
      pkgs.SDL2_gfx
      pkgs.SDL2_net
      pkgs.SDL2_ttf
      pkgs.gvfs
      pkgs.dconf
      pkgs.stdenv.cc.cc

    ];
    # mic noise removal
    #programs.noisetorch.enable = isFullSystem;
    programs.wireshark.enable = isFullSystem;
    programs.ssh.startAgent = true; # replace with home-manager services.ssh-agent.enable after 23.11


    services.tor.enable = isFullSystem;
    services.tor.client.enable = isFullSystem;
    services.trezord.enable = isFullSystem;

    hardware.logitech.wireless.enable = isFullSystem;
    hardware.logitech.wireless.enableGraphical = isFullSystem;
    hardware.keyboard.qmk.enable = isFullSystem;
    hardware.rtl-sdr.enable = isFullSystem;
    hardware.solo2.enable = isFullSystem;
    hardware.yubikey.enable = isFullSystem;

    environment.etc."nixos/flake.nix".source = "/home/${username}/Projects/dotfiles/flake.nix";
    environment.systemPackages = mkIf isFullSystem [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
    ];

    # explore virtualisation.kvmgt.enable for intel gpu sharing into vm
    virtualisation.docker.enable = isFullSystem;
    virtualisation.libvirtd.enable = mkDefault isFullSystem;

    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.users."${username}" = let
      homeDir = "/home/${username}";
    in {
      imports = [
          flake.self.homeModules.common
          ./ssh.nix
          flake.inputs.secrets.homemanagerModules.lriutzel
          flake.inputs.nix-index-database.hmModules.nix-index
          #flake.inputs.nixvim.homeManagerModules.nixvim
        ]
        ++ optionals ifTui [
          flake.self.homeModules.tui
        ]
        ++ optionals ifGraphical [
          flake.self.homeModules.gui
        ]
        ++ optionals isFullSystem [
          ./bah.nix
        ]
        ++ optionals config.machine.impermanence [
          ./impermanence.nix
        ];

      home.username = username;
      home.homeDirectory = mkOverride 10 homeDir;

      programs.bash.enable = ifTui;
      programs.command-not-found.enable = !isFullSystem;
      programs.git.extraConfig.safe.directory = "${homeDir}/Projects/dotfiles";

      programs.neovim.enable = true;
      programs.nix-index.enable = isFullSystem;
      programs.nix-index-database.comma.enable = isFullSystem;
      programs.mpv.enable = ifGraphical;
      programs.firefox.enable = ifGraphical;
      programs.fzf.enable = ifTui;
      programs.obs-studio = {
        enable = isFullSystem;
        plugins = [
          pkgs.obs-studio-plugins.wlrobs
          pkgs.obs-studio-plugins.obs-multi-rtmp
        ];
      };
      programs.openrct2.enable = isFullSystem;
      programs.ssh.enable = true;
      programs.starship.enable = ifGraphical; # Current config is slow. Need to investigate
      programs.thunderbird.enable = isFullSystem; # Email client
      programs.thunderbird.profiles = {
        lriutzel = {
          isDefault = true;
        };
      };
      programs.zoom-us.enable = isFullSystem;
      programs.zsh.enable = ifTui;

      services.gpg-agent.enable = isFullSystem;
      services.mopidy.enable = isFullSystem;
      services.syncthing.enable = isFullSystem;
      wayland.windowManager.sway.enable = isFullSystem;

      #programs.rbw = {
      #  enable = true;
      #  settings = {
      #    inherit email;
      #    lock_timeout = 300;
      #    pinentry = "gnome3";
      #  };
      #};
      #
      #
      xdg.desktopEntries = {
        mindforger = {
          name = "MindForger";
          genericName = "Personal knowledge management application";
          comment = "Thinking notebook and Markdown editor";
          icon = "${pkgs.mindforger}/share/icons/hicolor/256x256/apps/mindforger.png";
          exec = "${pkgs.mindforger}/bin/mindforger ${homeDir}/Documents/mindforger-repository";
          terminal = false;
          categories = [
            "Office"
            "Utility"
          ];
          mimeType = [
            "text/markdown"
          ];
        };
      };

      home.packages = with pkgs;
        []
        ++ optionals ifGraphical [
          # TUI tools but loading if graphical
          mqttui # mqtt tui

          # markdown tools
          mdcat # tui viewer
          mdp # markdown presentation
          mdr # tui viewer
          # mdv # tui viewer not in nixpkgs yet
          magic-wormhole-rs # Get things from one computer to another, safely.
        ]
        ++ optionals isFullSystem [
          emulsion # mimimal linux image viewer built in rust
          imv # minimal image viewer
          tor-browser-bundle-bin
          zathura # PDF / Document viewer
          # zeal # documentation browser

          #python39Packages.xdot # graphviz viewer # erro with pycairio compile
          graphviz

          ## Spotify - disabling and using webui
          #spotify-tui # spotifyd ui
          #spotifyd # music player no ui - spotify broke this i believe
          ## NonFree
          #spotify

          #gnome.vinagre # VNC view another computer
          #fractal # matrix client
          #fractal-next # matrix client. isn't compiling
          nheko # matrix client
          #mumble # voice chat application
          signal-desktop # messaging client

          ## Task/notes
          mindforger

          kodi-wayland

          gnome.file-roller # Archive manager
        ]
        ++ optionals isFullSystem [
          #helvum # pipewire patchbay # failing to build
          easyeffects # Audio effects

          # crypto
          trezorctl
          trezor_agent
          #trezor-suite # wasn't building
          #exodus # Cryptowallet
          #electron-cash # BCH walle
          libfido2 # interact with fido2 tokens

          # Media Management
          # filebot -get-subtitles --lang en -non-strict ./Season\ 03
          #filebot
          handbrake
          mkvtoolnix
          mediaelch


          #freeoffice # office suite UNFREE
          #tixati # bittorrent client - has been removed from nixpkgs as it is unfree and unmaintained
          blender # 3D render
          speedcrunch # gui calculator

          ## Video
          lbry

          ## Debugging
          wireshark
          gparted
          nmapsi4 # QT frontend for nmap

          ## Wine Apps
          wineApps.winbox
          #nur.repos.milahu.aether-server # Peer-to-peer ephemeral public communities

          # alt browser with ipfs builtin
          brave

          warp # transfer files between computers gui
          gnome.gnome-maps # map viewer
        ];
    };

    #modules.browsers.firefox = {
    #  enable = ifGraphical;
    #  profileName = "lriutzel";
    #};

    # user 1002 can only use tun0
    #    networking.firewall.extraCommands = "
    #iptables -A OUTPUT -o lo -m owner --uid-owner 1002 -j ACCEPT
    #iptables -A OUTPUT -o tun0 -m owner --uid-owner 1002 -j ACCEPT
    #iptables -A OUTPUT -m owner --uid-owner 1002 -j REJECT
    #    ";
  };
}
