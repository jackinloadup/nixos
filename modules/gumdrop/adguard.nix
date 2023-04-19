{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop.adguard = mkEnableOption "Enable adguard service";

  config = mkIf config.gumdrop.adguard {
    services.adguardhome = {
      enable = true;
      # opens port
      openFirewall = true;
      extraArgs = [ "--no-etc-hosts" ];
      port = 80; # Web gui
      host = "10.16.1.2";
    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    # Ensures that adguardhome doesn't stop until libvirtd has
    # This is simply to keep DNS running as long as possible if running on
    # a machine also running libvirtd.
    systemd.services.libvirtd.after = ["adguardhome.service"];
  };
}
