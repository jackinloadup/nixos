{ config, pkgs, nixosConfig, lib, inputs, ... }:

with lib;
let
  ifGraphical = if (nixosConfig.machine.sizeTarget > 1) then true else false;
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
