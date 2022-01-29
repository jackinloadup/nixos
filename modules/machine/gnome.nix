{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.windowManagers = mkOption {
    type = with types; nullOr (listOf (enum [ "gnome" ]));
  };

  config = mkIf (builtins.elem "gnome" config.machine.windowManagers) {
    programs.dconf.enable = true;

    # gnome has its own power management tool
    services.tlp.enable = mkForce false;

    services.xserver.displayManager.job.logToJournal = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}


