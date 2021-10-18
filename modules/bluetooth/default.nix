{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.bluetooth = mkEnableOption "Enable steam game platform";

  config = mkIf cfg.bluetooth {
    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      hsphfpd.enable = true; # High quality BT calls
    };
  };
}
