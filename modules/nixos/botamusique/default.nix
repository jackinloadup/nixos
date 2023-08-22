{
  lib,
  pkgs,
  config,
  ...
}:
# @TODO start something like agetty@tty1.service after autovt@tty1 stops
let
  inherit (lib) mkIf mkEnableOption;
  settings = import ../../../settings;
in {
  imports = [];

  config = mkIf config.services.botamusique.enable {
    services.botamusique = {
      settings = {
        server.host = "mumble.wiledesign.com";
        bot.username = "music";
      };
    };
  };
}
