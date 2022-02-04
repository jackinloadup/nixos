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

    # add if icon theme isn't a thing yet
    environment.systemPackages = with pkgs; [
      gnome.adwaita-icon-theme
      gnome.gnome-session
    ];

    services.xserver.displayManager.job.logToJournal = true;
    services.xserver.desktopManager.gnome.enable = true;

    environment.gnome.excludePackages = with pkgs; [
      gnome.cheese
      gnome-photos
      gnome.gnome-music
      gnome.gnome-terminal
      gnome.gedit
      epiphany
      evince
      gnome.gnome-characters
      gnome.totem
      gnome.tali
      gnome.iagno
      gnome.hitori
      gnome.atomix
      gnome-tour
      gnome.geary
    ];
  };
}

