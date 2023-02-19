{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
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
    services.pipewire.alsa.support32Bit = config.services.pipewire.alsa.enable;
  };
}
