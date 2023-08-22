{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption types;
in {
  config = mkIf config.services.xserver.windowManager.i3.enable {
    programs.dconf.enable = true;

    services.xserver = {
      enable = true;
      libinput.enable = true;
      displayManager.startx.enable = true;
      desktopManager.xterm.enable = false;

      windowManager.i3 = {
        extraPackages = [
          pkgs.dmenu #application launcher most people use
          pkgs.i3status # gives you the default i3 status bar
          pkgs.i3lock #default i3 screen locker
          pkgs.i3blocks #if you are planning on using i3blocks over i3status
          pkgs.arandr # gui for display management
          pkgs.feh # lightweight image viewer. Used for background in i3.
          pkgs.xorg.xrandr # tui for display management
          pkgs.xorg.xauth
          pkgs.xorg.xhost
          pkgs.xorg.xev
          pkgs.xorg.xinput
          pkgs.xorg.xf86inputjoystick
        ];
      };
    };
  };
}
