{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.gaming = mkEnableOption "Enable steam game platform";

  config = mkIf cfg.gaming {
    environment.systemPackages = with pkgs; [
      monado
      libgdiplus
      gnome.adwaita-icon-theme
    ];
    services.xserver = {
      enable = true;
      autorun = false;
      displayManager.defaultSession = "none+i3";
      modules = [ pkgs.xlibs.xf86inputjoystick ];

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };
    qt5.enable = true;
    qt5.platformTheme = "gtk2";
    qt5.style = "gtk2";
  };
}
