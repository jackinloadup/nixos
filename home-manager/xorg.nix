{ config, pkgs, nixosConfig, lib, inputs, ... }:

let
  inherit (lib) mkIf mkDefault;
  ifGraphical = nixosConfig.machine.sizeTarget > 1;
in {
  config = mkIf ifGraphical {
    home.keyboard = null; # only works with x11 i believe
    home.pointerCursor.x11.enable = mkDefault true;

    xsession = {
      enable = mkDefault true;
    };

    home.sessionVariables = {
      XAUTHORITY="${config.home.homeDirectory}/.Xauthority";
    };
  };
}
