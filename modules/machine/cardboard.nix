{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
in {
  options.programs.cardboard.enable = mkEnableOption "A scrollable, tiling Wayland compositor inspired on PaperWM";

  config = mkIf config.programs.cardboard.enable {
    environment.systemPackages = [ pkgs.cardboard ];
  };
}

