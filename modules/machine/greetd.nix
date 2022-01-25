{ lib, pkgs, config, ... }:

with lib;
{
  imports = [ ];

  options.machine.displayManager = mkOption {
    type = with types; nullOr (enum [ "greetd" ]);
  };

  config = mkIf (config.machine.displayManager == "greetd") {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet --time --cmd sway";
          user = "lriutzel";
        };
        initial_session = {
          command = "sway";
          user = "lriutzel";
        };
      };
    };
  };
}
