{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption mkForce types;
in {
  imports = [];

  config = mkIf config.services.xserver.displayManager.gdm.enable {
    programs.dconf.enable = true;

    # gnome has its own power management tool
    services.tlp.enable = mkForce false;

    services.xserver.enable = true;
    services.xserver.autorun = true;
    services.xserver.displayManager.lightdm.enable = false;
    services.xserver.displayManager.gdm = {
      wayland = true;
    };
  };
}
