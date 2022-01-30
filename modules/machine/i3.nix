{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.windowManagers = mkOption {
    type = with types; nullOr (listOf (enum [ "i3" ]));
  };

  config = mkIf (builtins.elem "i3" config.machine.windowManagers) {
    programs.dconf.enable = true;

    # gnome has its own power management tool
    services.tlp.enable = mkForce false;

    services.xserver = {
      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
          defaultSession = "none+i3";
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
       ];
      };
    };
  };

}

