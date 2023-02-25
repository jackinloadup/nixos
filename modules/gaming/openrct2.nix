{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf;
  cfg = config.machine;
in {
  config = mkIf cfg.gaming {
    environment.systemPackages = with pkgs; [
      openrct2
    ];

    # RollerCoaster Tycoon 2 openrct2 multiplayer
    networking.firewall.allowedTCPPorts = [ 11753 ];
    networking.firewall.allowedUDPPorts = [ 11753 ];
  };
}
