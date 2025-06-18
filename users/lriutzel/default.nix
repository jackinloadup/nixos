{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkOption mkIf mkDefault mkOverride optionals elem getExe;
  inherit (lib.types) listOf enum;

  cfg = config.machine;
  ifTui = cfg.sizeTarget > 0;
  ifGraphical = cfg.sizeTarget > 1;
  ifFull = cfg.sizeTarget > 2;
  fullSystems = ["reg" "riko" "zen" "kanye"];
  hostname = config.networking.hostName;
  isFullSystem = elem hostname fullSystems;
  userEnabled = elem username config.machine.users;

  first_and_last = "Lucas Riutzel";
  email = "lriutzel@gmail.com";
  username = "lriutzel";
in {

  imports = [
    #flake.inputs.nix-ld.nixosModules.nix-ld
    #./nix-ld.nix
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = listOf (enum [username]);
  };

  config = mkIf userEnabled {
    nix.settings.trusted-users = [username];

    #environment.systemPackages = [
    #  # From https://www.nyx.chaotic.cx/
    #  #
    #  # Input Leap is software that mimics the functionality of a KVM switch,
    #  # which historically would allow you to use a single keyboard and mouse
    #  # to control multiple computers by physically turning a dial on the box
    #  # to switch the machine you're controlling at any given moment. Input
    #  # Leap does this in software, allowing you to tell it which machine to
    #  # control by moving your mouse to the edge of the screen, or by using a
    #  # keypress to switch focus to a different system.
    #  #
    #  # https://github.com/input-leap/input-leap
    #  #input-leap #
    #];

    users.users."${username}" = {
      description = first_and_last;
      shell = pkgs.zsh;
      useDefaultShell = false; # used with  users.defaultUserShell
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
        "adbusers"
        #"libvirtd"
        #dip netdev plugdev
        # cdrom floppy
      ];
    };

    programs.adb.enable = isFullSystem;
    programs.appimage.enable = isFullSystem;
    programs.appimage.binfmt = true;
    #programs.captive-browser.enable = isFullSystem;
    programs.command-not-found.enable = isFullSystem;
    programs.chirp.enable = isFullSystem;
    programs.chromium.enable = isFullSystem;
    #programs.sniffnet.enable = isFullSystem;
    #programs.nix-ld.enable = isFullSystem;
    #programs.nix-ld.enable = true;
    programs.wireshark.enable = isFullSystem;
    services.udev = mkIf isFullSystem {
      extraRules = ''
        SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
      '';
    };


    services.tor.enable = mkDefault isFullSystem;
    services.tor.client.enable = mkDefault isFullSystem;
    services.trezord.enable = isFullSystem;

    hardware.logitech.wireless.enable = isFullSystem;
    hardware.logitech.wireless.enableGraphical = isFullSystem;
    hardware.keyboard.qmk.enable = isFullSystem;
    #hardware.rtl-sdr.enable = isFullSystem;
    hardware.solo2.enable = isFullSystem;
    hardware.yubikey.enable = isFullSystem;

    #environment.etc."nixos/flake.nix".source = "/home/${username}/Projects/dotfiles/flake.nix";
    environment.systemPackages = mkIf isFullSystem [
      #nix-plugins # Collection of miscellaneous plugins for the nix expression language
    ];
    #environment.pathsToLink = [
    #  "${pkgs.gnome.gnome-backgrounds}" # Backgrounds for GNOME used in sway. Needs to be set at system level
    #];

    security.sudo.extraRules = [{
      users = [ "lriutzel" ];
      commands = [
        {
          command = "${getExe config.boot.kernelPackages.turbostat} --Summary --quiet --show PkgWatt --num_iterations 1";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }];

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
          flake.inputs.nix-index-database.hmModules.nix-index
        ]
        ++ optionals ifTui [
          flake.self.homeModules.tui
        ]
        ++ optionals ifGraphical [
          flake.self.homeModules.gui
          flake.self.homeModules.video-editor
          ./gnome.nix
          ./hyprland.nix
        ]
        ++ optionals isFullSystem [
          #./bah.nix
        ]
        ++ optionals config.machine.impermanence [
          ./impermanence.nix
        ];

      home.username = username;
      home.homeDirectory = mkOverride 10 homeDir;

#home.persistence."/persist/home/${username}".enable = ifGraphical;
      #programs.waybar.settings."custom/pkgwatt" = {
      #  format = "{} Watts";
      #  max-length = 7;
      #  interval = 10;
      #  exec = pkgs.writeShellScript "pkgs-watts" ''
      #    sudo turbostat --Summary --quiet --show PkgWatt --num_iterations 1 | sed -n 2p
      #  '';
      #};

      programs.awscli.enable = isFullSystem;
      # pretty sure this is disable because useDefaultShell = false; doesn't
      # resolve some issue I was having
      #programs.bash.enable = ifTui;
      # The 'programs.command-not-found.enable' option is mutually exclusive
      # with the 'programs.nix-index.enableBashIntegration' option.
      #programs.command-not-found.enable = isFullSystem;

      #programs.neovim.enable = true;

      # mic noise removal
      #programs.noisetorch.enable = isFullSystem;
      programs.nix-index.enable = isFullSystem;
      #programs.nix-index.enableBashIntegration = config.programs.bash.enable;
      programs.nix-index.enableZshIntegration = config.programs.zsh.enable;
      programs.nix-index-database.comma.enable = isFullSystem;
      programs.mpv.enable = ifGraphical;
      programs.firefox.enable = ifGraphical;
      programs.fzf.enable = ifTui;
      programs.openrct2.enable = isFullSystem;
      programs.ssh.enable = true;
      programs.starship.enable = ifGraphical; # Current config is slow. Need to investigate
      programs.thunderbird.enable = false; #isFullSystem; # Email client
      programs.thunderbird.profiles = {
        lriutzel = {
          isDefault = true;
        };
      };
      programs.zoom-us.enable = false; # not using this anymore, YAY!
      programs.zsh.enable = ifTui;

      # per https://github.com/solokeys/solo2/discussions/108#discussioncomment-12253610
      # gpg doesn't support resident keys
      #services.gpg-agent.enable = isFullSystem;
      # is the agent needed anyway with services.gpg-agent?
      # yes, gpg-agent doesn't support resident keys. at least not the solo2.
      services.ssh-agent.enable = true;
      services.mopidy.enable = isFullSystem;
      services.syncthing.enable = isFullSystem;

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
      xdg.desktopEntries = mkIf ifGraphical {
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

      home.packages = []
        ++ optionals ifGraphical [
          #flake.inputs.scripts.packages.x86_64-linux.disk-burnin

          pkgs.bc
          #pkgs.pipexec # a neat tool to help with named pipes
        ]
        ++ optionals isFullSystem [
          pkgs.krusader # Norton/Total Commander clone for KDE
          pkgs.emulsion # mimimal linux image viewer built in rust
          pkgs.imv # minimal image viewer
          pkgs.tor-browser-bundle-bin
          pkgs.zathura # PDF / Document viewer
          # pkgs.zeal # documentation browser

          ## Spotify - disabling and using webui
          #spotify-tui # spotifyd ui
          #spotifyd # music player no ui - spotify broke this i believe
          ## NonFree
          #spotify

          #pkgs.gnome.vinagre # VNC view another computer
          #pkgs.fractal # matrix client
          #pkgs.fractal-next # matrix client. isn't compiling
          #pkgs.nheko # matrix client

          ## Task/notes
          pkgs.mindforger


          pkgs.file-roller # Archive manager
          pkgs.sysbench # benchmarking tool
          pkgs.postgresql # for psql to maintain nextcloud. Should be in shell

          # nvd diff /nix/var/nix/profiles/system-{296,297}-link
          pkgs.nvd # nix tool to diff
        ]
        ++ optionals isFullSystem [
          #flake.inputs.nix-software-center.packages.x86_64-linux.nix-software-center
          flake.inputs.scripts.packages.x86_64-linux.rebuild
          #helvum # pipewire patchbay # failing to build
          pkgs.easyeffects # Audio effects
          pkgs.mumble

          pkgs.kitty
          # crypto
          pkgs.trezorctl
          pkgs.trezor_agent
          #pkgs.trezor-suite # wasn't building
          #pkgs.exodus # Cryptowallet
          #pkgs.electron-cash # BCH walle
          pkgs.libfido2 # interact with fido2 tokens

          # Media Management
          # filebot -get-subtitles --lang en -non-strict ./Season\ 03
          #pkgs.filebot
          pkgs.mediaelch


          pkgs.qownnotes # markdown
          #pkgs.freeoffice # office suite UNFREE
          #pkgs.tixati # bittorrent client - has been removed from nixpkgs as it is unfree and unmaintained
          pkgs.speedcrunch # gui calculator

          ## Video
          pkgs.lbry

          ## Debugging
          pkgs.wireshark
          pkgs.gparted
          pkgs.nmapsi4 # QT frontend for nmap
          #pkgs.inxi # cli extensive system information

          ## Wine Apps
          pkgs.winbox4 # Mikrotik RouterOS GUI
          #nur.repos.milahu.aether-server # Peer-to-peer ephemeral public communities

          # alt browser with ipfs builtin
          pkgs.brave

          pkgs.gnome-maps # map viewer

          #pkgs.unzip # duh
          pkgs.lftp # ftp client
          pkgs.terminal-colors # print all the terminal colors

          # unar is HUGE at 930mb
          #pkgs.unar # An archive unpacker program GUI & TUI
          pkgs.units

          pkgs.sad # tool to search and replace
          pkgs.jless # json viewer
          pkgs.tealdeer # $tldr strace
          pkgs.nota # fancy cli calculator
          pkgs.bitwarden-cli
          pkgs.yt-dlp # there is an alt youtube-dl-lite
          pkgs.xdg-utils # for xdg-open
          pkgs.xdg-user-dirs # command to get the path to Downloads/Pictures/ect
          #nur.repos.ambroisie.comma # like nix-shell but more convinient
          pkgs.nixos-shell
          #  attribute 'default' missing
          #flake.inputs.nix-inspect.packages.default

          # TUI to GUI helpers
          pkgs.bfs # breadth-first version of the UNIX find command. might be faster than fd?
          pkgs.broot # tree directory viewer
          #pkgs.dragon-drop # in unstable its maybe xdragon
          ## networking
          pkgs.nethogs
          pkgs.ngrep
          ## fast adds chromium
          #fast-cli # bandwidth test through fast.com
          pkgs.nmap
          pkgs.television # blazingly fast general purpose fuzzy finder

          ## Audio
          pkgs.playerctl # TUI

          # Fun
          pkgs.asciiquarium # Fun aquarium animation
          pkgs.cmatrix # Fun matrix animation
          pkgs.nms # https://github.com/bartobri/no-more-secrets
          #pkgs.cava # Console-based Audio Visualizer for Alsa # build failure
          pkgs.nsnake # snake game
          pkgs.terminal-parrot # parrot in your terminal
          pkgs.pipes-rs # pipes terminal screensaver
          # https://tattoy.sh/ not yet in nixpkgs

          # benchmarking
          pkgs.geekbench # benchmarking tool
          pkgs.cpu-x # cpu info
          pkgs.lm_sensors

          # Disabled due to lack of use
          #pkgs.kodi-wayland
          #pkgs.warp # transfer files between computers gui
          #pkgs.textsnatcher #  com.github.rajsolai.textsnatcher maybe make alias
          #pkgs.super-productivity
          #pkgs.signal-desktop # messaging client
          #pkgs.magic-wormhole-rs # Get things from one computer to another, safely.

          #pkgs.libsForQt5.marble # map / globe viewer
          #pkgs.stellarium # planetarium

          #pkgs.anytype # distributed p2p local-first

          ## k8s
          #pkgs.k9s # Kubernetes CLI To Manage Your Clusters In Style

          ## spreadsheet stuffs
          #pkgs.sc-im # disabled due to insecure dependency: libxls-1.6.2
          #pkgs.visidata


          # todoist # task manager
          pkgs.systemctl-tui # tui for systemd
          # gping
          # impala # wifi tui
          # cms # audio/podcast?
          # tdf # PDF viewer
          # jqp # jq playground tui
          # rainfrog # tui database management
          # parallama # llm interface
          # wikitui # wikipedia tui
          # mc # midnight commander. file manager, haven't quite picked this up yet
          # somo # easier tcp/udp ports ect
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
