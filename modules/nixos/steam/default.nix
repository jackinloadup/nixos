{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  settings = import ../../../settings;
in {
  config = mkIf config.programs.steam.enable {
    programs.steam = {
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    environment.systemPackages = with pkgs; [
      steam-run
    ];

    hardware = {
      steam-hardware.enable = true;
      opengl.driSupport32Bit = true;
      pulseaudio.support32Bit = true;
    };

    services.pipewire.alsa.support32Bit = config.services.pipewire.alsa.enable;
  };
}
