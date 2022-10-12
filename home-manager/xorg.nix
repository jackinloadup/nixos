{ config, pkgs, nixosConfig, lib, inputs, ... }:

with lib;
let
  settings = import ../settings;
  ifGraphical = if (nixosConfig.machine.sizeTarget > 1) then true else false;
in {
  home.keyboard = null; # only works with x11 i believe
  home.pointerCursor.x11.enable = mkDefault ifGraphical;

  xsession = {
    enable = mkDefault true;
  };

  home.sessionVariables = {
    XAUTHORITY="${config.home.homeDirectory}/.Xauthority";
  };
}
