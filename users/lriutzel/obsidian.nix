{
  config,
  lib,
  pkgs,
  ...
}: let
  url = "https://app.v2.gather.town/app/obsidian-3812d4d3-1a3e-4e30-b603-b31c7b22e94f/join";
  icon = builtins.fetchurl {
    url = "https://framerusercontent.com/images/P5hrzskVvpcfIIXVKNXfzAkXLw.png";
    sha256 = "7c089864357290503eafa7ad216d78a6d4118ae70d07683745e1db1c7893e4c2";
  };
in {
  config = {
    xdg.desktopEntries.gather = {
      name = "Gather";
      genericName = "Gather";
      comment = "Open Gather in a chromeless browser";
      exec = "${pkgs.systemd}/bin/systemd-cat --identifier=gather-browser ${config.programs.chromium.package}/bin/chromium --app=${url}";
      icon = icon;
      terminal = false;
      categories = [
        "Utility"
      ];
    };
  };
}
