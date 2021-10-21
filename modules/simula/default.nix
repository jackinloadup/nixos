{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.simula = mkEnableOption "Enable steam game platform";

  config = mkIf cfg.simula {
    environment.systemPackages = with pkgs; [
      monado
    ];
  };
}
