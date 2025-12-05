{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce;
in {
  config = mkIf config.services.desktopManager.gnome.enable {
  # xdg-desktop-portal-gnome 44 causes delays in non-GNOME desktops
  #     https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
    programs.dconf.enable = true;

    # gnome has its own power management tool
    services.tlp.enable = mkForce false;

    services.displayManager.logToJournal = true;

    # add if icon theme isn't a thing yet
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
      pkgs.gnome-session
      pkgs.gnome-tweaks
      pkgs.dconf-editor

      #pkgs.gnome.nautilus-python # for nextcloud - for nextcloud-client
      pkgs.gnome.gvfs
    ];

    environment.gnome.excludePackages = [
      pkgs.cheese
      pkgs.gnome-photos
      pkgs.gnome-music
      pkgs.gnome-terminal
      #pkgs.gnome.gedit
      pkgs.epiphany
      pkgs.evince
      pkgs.gnome-characters
      pkgs.totem
      pkgs.tali
      pkgs.iagno
      pkgs.hitori
      pkgs.atomix
      pkgs.gnome-tour
      pkgs.geary
    ];
  };
}
