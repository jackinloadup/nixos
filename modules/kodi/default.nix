{ lib, pkgs, config, ... }:

with lib;
{
  imports = [];

  config = mkIf config.programs.kodi.enable {
  };
}

