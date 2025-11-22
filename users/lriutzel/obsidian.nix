{
  config,
  lib,
  pkgs,
  ...
}: let
  url = "https://app.v2.gather.town/app/obsidian-3812d4d3-1a3e-4e30-b603-b31c7b22e94f/join";
  icon = ./assets/gather.png;
in {
  config = {
    xdg.desktopEntries.syncthing = {
      name = "Gather";
      genericName = "Gather";
      comment = "Open Gather in a chromeless browser";
      exec = "${pkgs.systemd}/bin/systemd-cat --identifier=gather-browser ${config.programs.chromium.package}/bin/chromium --app=${url}";
      icon = "${icon}";
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
