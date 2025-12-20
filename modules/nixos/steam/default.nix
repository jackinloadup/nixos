{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  settings = import ../../../settings;
in
{
  config = mkIf config.programs.steam.enable {
    programs.steam = {
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    environment.systemPackages = [
      pkgs.steam-run
      #pkgs.BeatSaberModManager
      #pkgs.mangohud # fps hud
      #pkgs.protonup # install newer versions of proton with additional patches
      # home.sessionVariables = {
      #    STEAM_EXTRA_COMPAT_TOOLS_PATH =
      #    "\${HOME}/.steam/root/compatibilitytools.d";
      # }
      # lutris
      # heroic games
    ];

    hardware.steam-hardware.enable = true;

    services.pulseaudio.support32Bit = true;
    services.pipewire.alsa.support32Bit = config.services.pipewire.alsa.enable;

    # from https://github.com/Atemu/nixos-config/blob/d6a173bcf9c28f2b161f0b238baa0e9c62be2b7b/modules/gaming/module.nix#L20
    programs.gamemode.enable = true;

    boot.kernel.sysctl = {
      # SteamOS/Fedora default, can help with performance.
      "vm.max_map_count" = 2147483642;
    };

  };
}
