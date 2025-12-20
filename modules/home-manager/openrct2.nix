{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.programs.openrct2.enable = mkEnableOption "Enable OpenRCT2";

  config = mkIf config.programs.openrct2.enable {
    home.packages = [
      pkgs.openrct2
    ];
  };
}
