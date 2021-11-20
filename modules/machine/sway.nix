{ lib, pkgs, config, ... }:
with lib;
{
  imports = [ ];

  options.machine.sway = mkEnableOption "Enable sway";

  config = mkIf config.machine.sway {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        alacritty # look into foot term for ram usage

        wev
        wdisplays

        bemenu
        j4-dmenu-desktop
      ];
    };

    xdg = {
      portal = {
        enable = true;
        gtkUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
      };
    };
  };
}
