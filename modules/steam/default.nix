{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.steam = mkEnableOption "Enable steam game platform";

  config = mkIf cfg.steam {
    environment.systemPackages = with pkgs; [
      steam-run
    ];

    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    hardware = {
      opengl.driSupport32Bit = true;
      pulseaudio.support32Bit = true;
    };
  };
}
