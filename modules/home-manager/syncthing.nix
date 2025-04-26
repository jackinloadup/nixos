{
  config,
  lib,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  config = lib.mkIf config.services.syncthing.enable {
    xdg.desktopEntries.syncthing = {
      name = "Syncthing";
      genericName = "Syncthing";
      comment = "Open Syncthing in a browser";
      exec = "${pkgs.systemd}/bin/systemd-cat --identifier=syncthing-browser ${config.programs.chromium.package}/bin/chromium --app=http://localhost:8384";
      icon = "${pkgs.kdePackages.breeze-icons}/share/icons/breeze-dark/apps/48/syncthing.svg";
      terminal = false;
      categories = [
        "Utility"
      ];
    };

    services.syncthing = {
      extraOptions = [
        "--config=${config.xdg.configHome}/syncthing"
        "--data=${config.xdg.dataHome}/syncthing"
      ];
    };
  };
}
