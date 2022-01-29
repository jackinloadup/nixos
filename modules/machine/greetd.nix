{ lib, pkgs, config, ... }:

with lib;
let
  desktops = config.services.xserver.displayManager.sessionData.desktops;
  sessions = "${desktops}/share/wayland-sessions:${desktops}/share/xsessions";
in {
  imports = [ ];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum [ "greetd" ]);
  };

  config = mkIf (config.machine.displayManager == "greetd") {
    # keep systemd startup logs on tty1
    boot.kernelParams = [ "console=tty1" ];

    services.greetd = {
      enable = true;
      vt = 2; # use tty2 to stay away from systemd startup logs
      settings = {
        default_session = {
          command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet -i --sessions ${sessions} --time ";
          user = "greeter";
        };
        initial_session = {
          command = "sway";
          user = "lriutzel";
        };
      };
    };
  };
}
