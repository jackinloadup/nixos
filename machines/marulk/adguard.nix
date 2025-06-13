{ config, lib, ...}:
let
  inherit (lib) mkDefault;
in {
  config = {
    networking.firewall.allowedTCPPorts = [53];
    networking.firewall.allowedUDPPorts = [53];
    networking.interfaces.br0.ipv4.addresses = [{
      address = "10.16.1.2";
      prefixLength = 8;
    }];

    services.adguardhome = {
      enable = true;
      # opens port
      openFirewall = true;
      extraArgs = ["--no-etc-hosts"];
      port = 8001; # Web gui
      host = "10.16.1.2";
      settings = {
        #schema_version = 20;
        dns = {
          #allowed_clients = "10.16.0.0/8";
          edns_client_subnet = {
            enable = false;
          };
        };
      };
    };

    systemd.services."adguardhome".wants = ["network-online.target"];
    # Ensures that adguardhome doesn't stop until libvirtd has
    # This is simply to keep DNS running as long as possible if running on
    # a machine also running libvirtd.
    systemd.services."adguardhome".before = ["libvirtd.service"];
    #systemd.services.libvirtd.after = ["adguardhome.service"];

    services.nginx.virtualHosts."dns.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://${config.services.adguardhome.host}:${toString config.services.adguardhome.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
