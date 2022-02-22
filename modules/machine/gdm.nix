{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum [ "gdm" ]);
  };

  config = mkIf (config.machine.displayManager == "gdm") {
    programs.dconf.enable = true;

    # gnome has its own power management tool
    services.tlp.enable = mkForce false;

    services.xserver.enable = true;
    services.xserver.autorun = true;
    services.xserver.displayManager.lightdm.enable = false;
    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
