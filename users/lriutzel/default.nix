{ inputs, lib, pkgs, config, ... }:

let
  inherit (lib) mkOption mkIf mkOverride optionals;
  inherit (lib.types) listOf enum;

  cfg = config.machine;
  ifTui = cfg.sizeTarget > 0;
  ifGraphical = cfg.sizeTarget > 1;
  ifFull = cfg.sizeTarget > 2;
  settings = import ./settings.nix;
  username = settings.username;
in {
  imports = [
    inputs.nix-ld.nixosModules.nix-ld
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = listOf (enum [ username ]);
  };

  # If user is enabled
  config = mkIf (builtins.elem username config.machine.users) {

    nix.settings.trusted-users = [ username ];

    users.users."${username}" = with settings; {
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
        #dip netdev plugdev 
        # cdrom floppy
      ];
    };


    programs.nix-ld.enable = true;
    programs.wireshark.enable = ifFull;

    services.trezord.enable = ifGraphical;

    hardware.yubikey.enable = ifGraphical;

    environment.etc."nixos/flake.nix".source = "/home/${username}/dotfiles/flake.nix";
    environment.systemPackages = with pkgs; mkIf ifGraphical [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
      nmapsi4 # QT frontend for nmap
    ];
    environment.variables = {
        # Supports inputs.nix-ld
        NIX_LD_LIBRARY_PATH = lib.makeLibraryPath (config.systemd.packages ++ config.environment.systemPackages);
        NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
    };


    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.users."${username}" = let
      homeDir = "/home/${settings.username}";
    in {
      imports = [
        ../../home-manager/nix.nix
        ../../home-manager/default.nix
        ../../home-manager/dunst.nix
        ../../home-manager/firefox.nix
        ../../home-manager/foot.nix
        ../../home-manager/mpv.nix
        ../../home-manager/music.nix
        ../../home-manager/zsh.nix
        ./mobomo.nix
        inputs.secrets.homemanagerModules.lriutzel
      ]
      ++ optionals ifTui [
        ../../home-manager/tui.nix
      ]
      ++ optionals ifGraphical [
        ../../home-manager/alacritty.nix
        ../../home-manager/development.nix
        ../../home-manager/graphical.nix
        ../../home-manager/openrct2.nix
        ../../home-manager/gpg.nix
        ../../home-manager/i3.nix
        ../../home-manager/impermanence.nix
        ../../home-manager/neovim/default.nix
        ../../home-manager/sway/default.nix
        ../../home-manager/syncthing.nix
        ../../home-manager/xorg.nix
      ]
      ++ optionals ifFull [
      ];

      home.username = settings.username;
      home.homeDirectory = mkOverride 10 homeDir;

      home.sessionVariables = {
        NIXOS_CONFIG="${homeDir}/dotfiles/flake.nix";
        NIX_PATH="nixos-config=${homeDir}/dotfiles/flake.nix:$NIX_PATH";
      };

      programs.git.extraConfig.safe.directory = "${homeDir}/dotfiles";

      programs.mpv.enable = ifGraphical;
      programs.firefox.enable = ifGraphical;
      programs.fzf.enable = ifTui;
      programs.thunderbird.enable = ifGraphical; # Email client
      programs.thunderbird.profiles = {
        lriutzel = {
          isDefault = true;

        };
      }; # Email client
      programs.obs-studio = {
        enable = ifGraphical;
        plugins = [ 
          pkgs.obs-studio-plugins.wlrobs
          pkgs.obs-studio-plugins.obs-multi-rtmp
        ];
      };
      programs.zsh.enable = ifTui;
      programs.starship.enable = ifTui;

      services.gpg-agent.enable = ifGraphical;
      services.syncthing.enable = ifGraphical;

      #programs.rbw = {
      #  enable = true;
      #  settings = {
      #    inherit email;
      #    lock_timeout = 300;
      #    pinentry = "gnome3";
      #  };
      #};

      home.packages = with pkgs; []
      ++ optionals ifGraphical [ # TUI tools but loading if graphical
        unstable.mqttui # mqtt tui

        # markdown tools
        mdcat # tui viewer
        mdp # markdown presentation
        mdr # tui viewer
        # mdv # tui viewer not in nixpkgs yet
      ]
      ++ optionals ifGraphical [
        emulsion # mimimal linux image viewer built in rust
        imv # minimal image viewer
        tor-browser-bundle-bin
        zathura # PDF / Document viewer
        # zeal # documentation browser

        python39Packages.xdot # graphviz viewer
        graphviz

        # Spotify
        spotify-tui # spotifyd ui
        spotifyd # music player no ui
        # NonFree
        spotify

        #gnome.vinagre # VNC view another computer
        fractal # matrix client
        nheko   # matrix client
        #mumble # voice chat application
        signal-desktop # messaging client

        ## Task/notes
        mindforger

        # Media Management
        mediaelch

        kodi-wayland
      ]
      ++ optionals ifFull [
        #helvum # pipewire patchbay # failing to build
        easyeffects # Audio effects

        # crypto
        trezorctl
        trezor_agent
        #trezor-suite # wasn't building
        #exodus # Cryptowallet
        #electron-cash # BCH walle

        # Media Management
        #filebot
        mkvtoolnix

        #freeoffice # office suite UNFREE
        tixati # bittorrent client
        blender # 3D render
        cawbird # twitter client
        speedcrunch # gui calculator

        ## Video
        handbrake
        lbry

        ## Debugging
        wireshark
        gparted

        ## Wine Apps
        wineApps.winbox
        #nur.repos.milahu.aether-server # Peer-to-peer ephemeral public communities
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
