
{ inputs, lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  home-manager = inputs.home-manager;
in {
  imports = [
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = with types; listOf (enum [ "kodi" ]);
  };

  # If user is enabled
  config = mkIf (builtins.elem "kodi" config.machine.users) {
    users.users.kodi = with settings; {
      isNormalUser = true;
      password = "kodi";
      extraGroups = [
        # Needed to access /dev/ttyACM0, which is used by libcec
        # for Pulse-Eight USB CEC Adapter
        "dialout"
        "audio"
        "video"
        "input"
        #"lock" # per https://wiki.archlinux.org/title/Kodi#Xsession_with_NoDM
      ];
    };

    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.users.kodi = {
      imports = [
        ../../home-manager/i3.nix
        ./sway.nix
      ];
      home.stateVersion = "21.05";

      xdg.enable = lib.mkForce true; # needed for environment variables used in utils

      programs.bash = {
        enable = true;
        profileExtra = ''
          if shopt -q login_shell; then
              [[ -f ~/.bashrc ]] && source ~/.bashrc
              [[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]] && exec startx
          else
              exit 1 # Somehow this is a non-bash or non-login shell.
          fi
        '';
      };

      programs.kodi = {
        enable = true;
        package = pkgs.kodi-wayland.withPackages (exts: [
          exts.youtube
          exts.netflix
          exts.joystick
          exts.controller-topology-project
          exts.libretro
          exts.libretro-snes9x
          exts.libretro-genplus
          exts.inputstreamhelper
          exts.inputstream-rtmp
          exts.inputstream-adaptive
          exts.inputstream-ffmpegdirect
          exts.iagl
          exts.keymap
        ]);
        addonSettings = {
          "service.xbmc.versioncheck".versioncheck_enable = "false";
        };
        #settings = {
        #  cache = {
        #    buffermode = 1; # buffer all filesystems
        #    #memorysize = ; # 
        #    readfactor = 4.0; # determines the max readrate in terms of readfactor * avg bitrate of a video file
        #  };
        #  seeksteps = "15, 30, 30, 60, 60, 300";
        #};
      };

      xsession.windowManager.i3.config.startup = [
        { command = "kodi"; }
      ];
    };

    # https://github.com/nixcon/nixcon-video-infra/blob/13b5fc1e4cd12c1ce99defc60ee59e6cd3631880/nixpkgs/pkgs/misc/emulators/retroarch/kodi-advanced-launchers.nix
    # above contains method for handling kodi to retroarch


    #services.cage.user = "kodi";
    #services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    #services.cage.enable = true;


    environment.systemPackages = with pkgs; [
      libcec
      kodi-retroarch-advanced-launchers
      retroarchFull
      sixpair
    ];

  };
}
