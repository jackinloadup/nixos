{ lib, pkgs, config, ... }:
with lib;
let
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop.adguard = mkEnableOption "Enable adguard service";

  config = mkIf config.gumdrop.adguard {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      extraArgs = [];
      port = 80; # Web gui
      host = "10.16.1.2";
    };

    networking.firewall.allowedTCPPorts = [ 53 80 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
