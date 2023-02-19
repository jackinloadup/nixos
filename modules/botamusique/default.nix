{ lib, pkgs, config, ... }:

# @TODO start something like agetty@tty1.service after autovt@tty1 stops
let
  inherit (lib) mkIf mkEnableOption;
  settings = import ../../settings;
in {
  imports = [];

  options.machine.botamusique = mkEnableOption "Enable botamusique";

  config = mkIf config.machine.botamusique {
    services.botamusique = {
      enable = true;
      settings = {
        server.host = "mumble.wiledesign.com";
        bot.username = "music";
      };
    };
  };
}
