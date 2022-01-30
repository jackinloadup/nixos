{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.gaming = mkEnableOption "Enable extra options only needed for gaming";

  config = mkIf cfg.gaming {
    environment.systemPackages = with pkgs; [
      monado
      lighthouse-steamvr
      libgdiplus
      gnome.adwaita-icon-theme

      # xorg stuff
      xorg.xhost # for `xhost si:localuser:root`

      nur.repos.dukzcry.gamescope
    ];
    services.xserver = {
      modules = [ pkgs.xlibs.xf86inputjoystick ];
    };
    qt5.enable = true;
    qt5.platformTheme = "gtk2";
    qt5.style = "gtk2";
  };
}
