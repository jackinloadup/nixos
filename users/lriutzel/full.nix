{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkOption mkIf mkDefault mkOverride optionals elem getExe;
  inherit (lib.types) listOf enum;

  username = "lriutzel";
in {
  imports = [
    #flake.inputs.nix-ld.nixosModules.nix-ld
    #./nix-ld.nix
  ];

  config = {
    users.users."${username}".extraGroups = [
      "wireshark"
      "dialout" # needed for flashing serial devices ttyUSB0
      "ipfs"
      #"libvirtd"
      #dip netdev plugdev
      # cdrom floppy
    ];

    #environment.etc."nixos/flake.nix".source = "/home/${username}/Projects/dotfiles/flake.nix";

    #environment.systemPackages = [
    #  pkgs.nix-plugins # Collection of miscellaneous plugins for the nix expression language
    #
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

    hardware.keyboard.qmk.enable = true;
    #hardware.rtl-sdr.enable = true;

    programs.adb.enable = true;
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    programs.chirp.enable = true;
    #programs.sniffnet.enable = true;
    #programs.nix-ld.enable = true;
    #programs.nix-ld.enable = true;
    programs.wireshark.enable = true;

    services.tor.enable = mkDefault true;
    services.tor.client.enable = mkDefault true;

    services.udev = {
      extraRules = ''
        SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
      '';
    };

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
    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = mkDefault true;

    # user 1002 can only use tun0
    #    networking.firewall.extraCommands = "
    #iptables -A OUTPUT -o lo -m owner --uid-owner 1002 -j ACCEPT
    #iptables -A OUTPUT -o tun0 -m owner --uid-owner 1002 -j ACCEPT
    #iptables -A OUTPUT -m owner --uid-owner 1002 -j REJECT
    #    ";

    home-manager.users."${username}" = let
      homeDir = "/home/${username}";
    in {
      imports = [
          flake.self.homeModules.video-editor
      ];

      programs.awscli.enable = true;

      # mic noise removal
      #programs.noisetorch.enable = true;

      #programs.openrct2.enable = true; # disabled due to discord-rpc

      #programs.thunderbird.enable = false; #true; # Email client
      #programs.thunderbird.profiles = {
      #  lriutzel = {
      #    isDefault = true;
      #  };
      #};

      services.syncthing.enable = true;

      #xdg.desktopEntries = mkIf ifGraphical {
      #  mindforger = {
      #    name = "MindForger";
      #    genericName = "Personal knowledge management application";
      #    comment = "Thinking notebook and Markdown editor";
      #    icon = "${pkgs.mindforger}/share/icons/hicolor/256x256/apps/mindforger.png";
      #    exec = "${pkgs.mindforger}/bin/mindforger ${homeDir}/Documents/mindforger-repository";
      #    terminal = false;
      #    categories = [
      #      "Office"
      #      "Utility"
      #    ];
      #    mimeType = [
      #      "text/markdown"
      #    ];
      #  };
      #};

      home.packages = [
        #flake.inputs.scripts.packages.x86_64-linux.disk-burnin
        pkgs.krusader # Norton/Total Commander clone for KDE
        pkgs.tor-browser-bundle-bin

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

        pkgs.sysbench # benchmarking tool
        pkgs.postgresql # for psql to maintain nextcloud. Should be in shell

        # nvd diff /nix/var/nix/profiles/system-{296,297}-link
        pkgs.nvd # nix tool to diff

        #flake.inputs.nix-software-center.packages.x86_64-linux.nix-software-center
        flake.inputs.scripts.packages.x86_64-linux.rebuild
        #helvum # pipewire patchbay # failing to build
        pkgs.easyeffects # Audio effects
        pkgs.mumble

        # Media Management
        # filebot -get-subtitles --lang en -non-strict ./Season\ 03
        #pkgs.filebot
        pkgs.mediaelch

        pkgs.qownnotes # markdown
        #pkgs.freeoffice # office suite UNFREE
        #pkgs.tixati # bittorrent client - has been removed from nixpkgs as it is unfree and unmaintained

        ## Video
        pkgs.lbry

        ## Debugging
        pkgs.wireshark
        pkgs.gparted
        pkgs.nmapsi4 # QT frontend for nmap

        ## Wine Apps
        pkgs.winbox4 # Mikrotik RouterOS GUI
        #nur.repos.milahu.aether-server # Peer-to-peer ephemeral public communities

        pkgs.gnome-maps # map viewer

        pkgs.ubpm # universal blood pressure monitor

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

        pkgs.mission-center # great cpu/network/disk monitor gui
      ];
    };
  };

}
