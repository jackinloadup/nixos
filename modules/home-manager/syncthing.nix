{ config
, lib
, pkgs
, ...
}: {
  config = lib.mkIf config.services.syncthing.enable {
    # Use --home to match the path that syncthing-init expects
    # (home-manager hardcodes syncthing_dir to $XDG_STATE_HOME/syncthing)
    services.syncthing.extraOptions = [
      "--home=${config.xdg.stateHome}/syncthing"
    ];

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

  };
}
