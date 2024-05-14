{
  config,
  pkgs,
  nixosConfig,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
in {
  #config = mkIf nixosConfig.services.xserver.enable {
  #  home.keyboard = null; # only works with x11 i believe
  #  home.pointerCursor.x11.enable = mkDefault true;

  #  xsession = {
  #    enable = mkDefault true;
  #  };

  #  home.sessionVariables = {
  #    XAUTHORITY = "${config.home.homeDirectory}/.Xauthority";
  #  };
  #};
}
