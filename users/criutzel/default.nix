{
  lib,
  pkgs,
  config,
  flake,
  ...
}: let
  inherit (lib) mkOption mkIf mkDefault mkOverride optionals elem;
  inherit (lib.types) listOf enum;

  first_and_last = "Christine Riutzel";
  username = "criutzel";
in {
  # Make user available in user list
  options.machine.users = mkOption {
    type = listOf (enum [username]);
  };

  config = {
    users.users."${username}" = {
      description = first_and_last;
      shell = pkgs.zsh;
      useDefaultShell = false;
      isNormalUser = true;
      extraGroups = [
        "audio"
        "video"
        "input"
        "networkmanager"
        "ipfs"
        "plugdev"
        "adbusers"
      ];
    };

    hardware.logitech.wireless.enable = mkDefault true;
    hardware.logitech.wireless.enableGraphical = mkDefault true;
    hardware.solo2.enable = mkDefault true;
    hardware.yubikey.enable = mkDefault true;

    programs.adb.enable = true;

    services.flatpak.enable = true;

    home-manager.users."${username}" = let
      homeDir = "/home/${username}";
    in {
      imports = [
        flake.self.homeModules.common
        flake.self.homeModules.tui
        flake.self.homeModules.gui
        ./gnome.nix
      ];
      home.username = username;
      home.homeDirectory = homeDir;
      home.packages = [
        # ART
        pkgs.krita
        #pkgs.blender
        pkgs.handbrake
        pkgs.gimp
        pkgs.inkscape

        pkgs.media-downloader # youtube-dl gui

        pkgs.warp # transfer files between computers gui

        pkgs.bottles # wine gui

        pkgs.flatpak
        pkgs.gnome-software

        pkgs.mpv # video player
        pkgs.vlc # video player
        pkgs.ffmpeg # multimedia swiss army knife.
        pkgs.ffmpegthumbnailer # video thumbnailer needed for nautilus thumbnails
        pkgs.imagemagick # image manipulation

        # Gstreamer
        # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
        pkgs.gst_all_1.gstreamer
        # Common plugins like "filesrc" to combine within e.g. gst-launch
        pkgs.gst_all_1.gst-plugins-base
        # Specialized plugins separated by quality
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.gst_all_1.gst-plugins-ugly
        # Plugins to reuse ffmpeg to play almost every video format
        pkgs.gst_all_1.gst-libav
        # Support the Video Audio (Hardware) Acceleration API
        pkgs.gst_all_1.gst-vaapi

        # Office work
        pkgs.libreoffice
        pkgs.lftp # ftp client
        pkgs.filezilla # ftp client
        pkgs.unar # An archive unpacker program
      ];
      xdg.systemDirs.data = [
        "/usr/share"
        "/var/lib/flatpak/exports/share"
        "$HOME/.local/share/flatpak/exports/share"
      ];

      programs.neovim.enable = false;
      programs.firefox.enable = true;
      programs.chromium.enable = true;
      programs.obs-studio = {
        enable = true;
        plugins = [
          pkgs.obs-studio-plugins.wlrobs
          pkgs.obs-studio-plugins.obs-multi-rtmp
        ];
      };
      programs.starship.enable = true; # Current config is slow. Need to investigate
      programs.zoom-us.enable = true;
      programs.zsh.enable = true;

      services.ssh-agent.enable = true;
      services.syncthing.enable = true;
    };
  };
}

