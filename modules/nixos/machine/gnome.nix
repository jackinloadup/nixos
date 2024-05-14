{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce;
in {
  config = mkIf config.services.xserver.desktopManager.gnome.enable {
  # xdg-desktop-portal-gnome 44 causes delays in non-GNOME desktops
  #     https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
    programs.dconf.enable = true;

    # gnome has its own power management tool
    services.tlp.enable = mkForce false;

    services.displayManager.logToJournal = true;

    # add if icon theme isn't a thing yet
    environment.systemPackages = [
      pkgs.gnome.adwaita-icon-theme
      pkgs.gnome.gnome-session
      pkgs.gnome.gnome-tweaks
      pkgs.gnome.dconf-editor
    ];

    environment.gnome.excludePackages = [
      pkgs.gnome.cheese
      pkgs.gnome-photos
      pkgs.gnome.gnome-music
      pkgs.gnome.gnome-terminal
      #pkgs.gnome.gedit
      pkgs.epiphany
      pkgs.evince
      pkgs.gnome.gnome-characters
      pkgs.gnome.totem
      pkgs.gnome.tali
      pkgs.gnome.iagno
      pkgs.gnome.hitori
      pkgs.gnome.atomix
      pkgs.gnome-tour
      pkgs.gnome.geary
    ];
  };
}
