{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.sdr = mkEnableOption "Enable SDR platform";

  config = mkIf cfg.sdr {
    hardware.rtl-sdr.enable = true;

    users.users.lriutzel.extraGroups = [ "plugdev" ];

    environment.systemPackages = with pkgs; [
      cubicsdr
      gnuradio # there is a minimal version
      sdrangel
      nrsc5
      gqrx
    ];
  };
}
