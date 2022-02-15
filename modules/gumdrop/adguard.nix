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
      port = 3000; # Web gui
      host = "0.0.0.0";
    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
