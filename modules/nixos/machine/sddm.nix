{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.xserver.displayManager.sddm.enable {
    #services.xserver.enable = true;
    #services.xserver.autorun = true;
    services.xserver.displayManager.lightdm.enable = false;
    services.xserver.displayManager.sddm = {
      wayland = true;
    };
  };
}
