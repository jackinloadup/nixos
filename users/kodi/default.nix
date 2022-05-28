
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
    nix.trustedUsers = [ "kodi" ];

    users.users.kodi = with settings; {
      isNormalUser = true;
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

    services.xserver.desktopManager.kodi.package = pkgs.kodi-wayland.withPackages (exts: [
      exts.youtube
      exts.netflix
    ]);


    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.users.kodi = {
      imports = [
        #../../home-manager
        ./sway.nix
      ];
      home.stateVersion = "21.05";

      xdg.enable = lib.mkForce true; # needed for environment variables used in utils

      programs.kodi = {
        enable = true;
        package = pkgs.kodi-wayland.withPackages (exts: [
          exts.youtube
          exts.netflix
        ]);
        addonSettings = {
          "service.xbmc.versioncheck".versioncheck_enable = "false";
        };
      };
    };

    # https://github.com/nixcon/nixcon-video-infra/blob/13b5fc1e4cd12c1ce99defc60ee59e6cd3631880/nixpkgs/pkgs/misc/emulators/retroarch/kodi-advanced-launchers.nix
    # above contains method for handling kodi to retroarch


    #services.cage.user = "kodi";
    #services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    #services.cage.enable = true;


    environment.systemPackages = with pkgs; [
      libcec
    ];

  };
}
