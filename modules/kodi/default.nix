{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [];

  config =
    mkIf config.programs.kodi.enable {
    };
}
