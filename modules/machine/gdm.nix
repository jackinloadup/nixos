{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum [ "gdm" ]);
  };

  config = mkIf (config.machine.displayManager == "gdm") {
    services.xserver.autorun = true;
    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = false;
    };
  };
}
