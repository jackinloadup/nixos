{ lib, pkgs, config, ... }:

# @TODO start something like agetty@tty1.service after autovt@tty1 stops
with lib;
let
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
