{ lib, pkgs, config, ... }:

with lib;
{
  imports = [];

  options.programs.kodi.enable = mkEnableOption "Enable kodi";

  config = mkIf config.programs.kodi.enable {
    # Define a user account
    users.extraUsers.kodi.isNormalUser = true;
    services.cage.user = "kodi";
    services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    services.cage.enable = true;
  };
}

