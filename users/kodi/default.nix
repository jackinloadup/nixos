{ flake
, lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkOption types;
  inherit (builtins) elem;
  home-manager = flake.inputs.home-manager;
in
{
  imports = [
  ];

  # Make user available in user list
  options.machine.users = mkOption {
    type = with types; listOf (enum [ "kodi" ]);
  };

  # If user is enabled
  config = mkIf (elem "kodi" config.machine.users) {
    users.users.kodi = {
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

    home-manager.users.kodi = {
      imports = [
        flake.self.homeModules.common
        flake.self.homeModules.tui
        #../../modules/home-manager/default.nix
        #../../modules/home-manager/nix.nix
        #./kodi.nix
        #./sway.nix
        #./i3.nix
      ];
    };

    # https://github.com/nixcon/nixcon-video-infra/blob/13b5fc1e4cd12c1ce99defc60ee59e6cd3631880/nixpkgs/pkgs/misc/emulators/retroarch/kodi-advanced-launchers.nix
    # above contains method for handling kodi to retroarch

    #services.cage.user = "kodi";
    #services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    #services.cage.enable = true;

    environment.systemPackages = with pkgs; [
      libcec
      htop
      bark
      #kodi-retroarch-advanced-launchers
      #retroarchFull
      #sixpair # usb pair playstation controllers
    ];

    #nixpkgs.config.retroarch = {
    #  enableBsnes = true;
    #  enableDolphin = true;
    #  enableMGBA = true;
    #  enableMAME = true;
    #};
  };
}
