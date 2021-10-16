{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.steam = mkEnableOption "Enable steam game platform";

  config = mkIf cfg.steam {
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    # add config above here
  };
}
