{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkOption types;
in {
  imports = [ ];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum [ "sddm" ]);
  };

  config = mkIf (config.machine.displayManager == "sddm") {

    #services.xserver.enable = true;
    #services.xserver.autorun = true;
    services.xserver.displayManager.lightdm.enable = false;
    services.xserver.displayManager.sddm = {
      enable = true;
      wayland = true;
    };
  };
}
