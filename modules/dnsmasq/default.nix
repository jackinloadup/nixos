{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.dnsmasq.enable {
    #environment.systemPackages = [
    #  pkgs.kubectl
    #];

    #networking.firewall.allowedTCPPorts = [6443];

    services.dnsmasq = {
      alwaysKeepRunning = true;
      resolveLocalQueries = true;

      settings = {
        server = [
          "8.8.8.8"
          "8.8.4.4"
        ];
        listen-address="127.0.0.1";
        interface="lo";
        bind-interfaces = true;
      };
    };
  };
}

