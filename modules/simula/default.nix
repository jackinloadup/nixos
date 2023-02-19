{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.simula = mkEnableOption "Enable Simula VR platform";

  config = mkIf cfg.simula {
    environment.systemPackages = with pkgs; [
      monado
    ];
  };
}
