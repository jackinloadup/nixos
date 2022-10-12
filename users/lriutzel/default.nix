{ inputs, lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ./settings.nix;
  ifTui = if (cfg.sizeTarget > 0) then true else false;
  ifGraphical = if (cfg.sizeTarget > 1) then true else false;
  ifFull = if (cfg.sizeTarget > 2) then true else false;
in {
  imports = [
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = with types; listOf (enum [ "lriutzel" ]);
  };

  # If user is enabled
  config = mkIf (builtins.elem "lriutzel" config.machine.users) {
    nix.trustedUsers = [ "lriutzel" ];

    users.users.lriutzel = with settings; {
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

    environment.etc."nixos/flake.nix".source = "/home/lriutzel/dotfiles/flake.nix";

    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.users.lriutzel = let
      homeDir = "/home/${settings.username}";
    in {
      imports = [
        ../../home-manager/nix.nix
        ../../home-manager/default.nix
        ../../home-manager/zsh.nix
      ]
      ++ lib.optionals ifTui [
        ../../home-manager/tui.nix
      ]
      ++ lib.optionals ifGraphical [
        ../../home-manager/alacritty.nix
        ../../home-manager/dunst.nix
        ../../home-manager/firefox.nix
        ../../home-manager/graphical.nix
        ../../home-manager/gpg.nix
        ../../home-manager/foot.nix
        ../../home-manager/i3.nix
        ../../home-manager/impermanence.nix
        ../../home-manager/mpv.nix
        ../../home-manager/neovim/default.nix
        ../../home-manager/sway/default.nix
        ../../home-manager/xorg.nix
        #./task-warrior
        #./zoom.nix
      ]
      ++ lib.optionals ifFull [
        ../../home-manager/development.nix
      ];

      home.username = settings.username;
      home.homeDirectory = lib.mkOverride 10 homeDir;

      home.sessionVariables = {
        NIXOS_CONFIG="$HOME/dotfiles/flake.nix";
        NIX_PATH="nixos-config=/home/lriutzel/dotfiles/flake.nix:$NIX_PATH";
      };

      programs.git.extraConfig.safe.directory = "${homeDir}/dotfiles";

      home.packages = with pkgs; []
      ++ lib.optionals ifGraphical [ # TUI tools but loading if graphical
        fzf
        unstable.mqttui # mqtt tui

        # markdown tools
        mdcat # tui viewer
        mdp # markdown presentation
        mdr # tui viewer
        # mdv # tui viewer not in nixpkgs yet
      ]
      ++ lib.optionals ifGraphical [
        emulsion # mimimal linux image viewer built in rust
        imv # minimal image viewer
        #tor-browser-bundle-bin
        zathura # PDF / Document viewer

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
        thunderbird # Email client
        #mumble # voice chat application
        signal-desktop # messaging client

        ## Task/notes
        mindforger
      ]
      ++ lib.optionals ifFull [
        unstable.helvum # pipewire patchbay
        easyeffects # Audio effects

        # crypto
        trezorctl
        trezor_agent
        trezor-suite
        #exodus # Cryptowallet
        #electron-cash # BCH walle

        # Media Management
        mediaelch
        #filebot
        mkvtoolnix

        #freeoffice # office suite UNFREE
        tixati # bittorrent client
        #nur.repos.arc.packages.mumble_1_4
        blender # 3D render
        cawbird # twitter client
        speedcrunch # gui calculator

        ## Video
        handbrake
        lbry
        obs-studio
        obs-studio-plugins.wlrobs
        obs-studio-plugins.obs-multi-rtmp

        ## Debugging
        wireshark
        gparted

        ## Wine Apps
        wineApps.winbox

        kodi-wayland
      ];
    };

    programs.wireshark.enable = ifFull;

    services.trezord.enable = ifGraphical;

    environment.systemPackages = with pkgs; mkIf ifGraphical [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
      #nmap-graphical # support removed due to its python2 dependency
      #nur.repos.milahu.aether-server # Peer-to-peer ephemeral public communities
    ];

    hardware.yubikey.enable = ifGraphical;

    modules.browsers.firefox = {
      enable = ifGraphical;
      profileName = "lriutzel";
    };

    # user 1002 can only use tun0
#    networking.firewall.extraCommands = "
#iptables -A OUTPUT -o lo -m owner --uid-owner 1002 -j ACCEPT
#iptables -A OUTPUT -o tun0 -m owner --uid-owner 1002 -j ACCEPT
#iptables -A OUTPUT -m owner --uid-owner 1002 -j REJECT
#    ";
  };
}
