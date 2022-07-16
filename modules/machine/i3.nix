{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.windowManagers = mkOption {
    type = with types; nullOr (listOf (enum [ "i3" ]));
  };

  config = mkIf (builtins.elem "i3" config.machine.windowManagers) {
    programs.dconf.enable = true;

    services.xserver = {
      enable = true;
      libinput.enable = true;
      displayManager.startx.enable = true;
      desktopManager.xterm.enable = false;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
          arandr # gui for display management
          feh # lightweight image viewer. Used for background in i3.
          xorg.xrandr # tui for display management
          xorg.xauth
          xorg.xhost
          xorg.xev
          xorg.xinput
          xorg.xf86inputjoystick
       ];
      };
    };
  };

}

