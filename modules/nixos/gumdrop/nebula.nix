{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf types mkOption;

  hostname = config.networking.hostName;
in
{
  options.gumdrop.nebula = {
    lighthouse = {
      enable = mkEnableOption "Make Nebula lighthouse";
      endpoint = mkOption {
        type = types.str;
        example = "example.host.com:4242";
        description = "Public endpoint for the lighthouse";
        default = "vpn.lucasr.com:4242";
      };
    };
    client = {
      enable = mkEnableOption "Make Nebula client";
      ip = mkOption {
        type = types.str;
        example = "10.101.0.2/24";
        description = "IP address on the Nebula network";
      };
    };
  };

  config =
    let
      cfg = config.gumdrop.nebula;
      isEnabled = cfg.lighthouse.enable || cfg.client.enable;
    in
    mkIf isEnabled {
      # Open firewall for Nebula
      networking.firewall.allowedUDPPorts = [ 4242 ];

      services.nebula.networks.gumdrop = {
        enable = true;

        # Certificate paths from agenix secrets
        ca = config.age.secrets.nebula-ca.path;
        cert = config.age.secrets."nebula-${hostname}-cert".path;
        key = config.age.secrets."nebula-${hostname}-key".path;

        # Lighthouse configuration
        isLighthouse = cfg.lighthouse.enable;
        isRelay = cfg.lighthouse.enable;

        lighthouses = mkIf cfg.client.enable [
          "10.101.0.1"
        ];

        staticHostMap = mkIf cfg.client.enable {
          "10.101.0.1" = [
            cfg.lighthouse.endpoint
          ];
        };

        settings = {
          # Punch through NAT
          punchy = {
            punch = true;
            respond = true;
          };

          # Relay configuration for lighthouse
          relay = mkIf cfg.lighthouse.enable {
            am_relay = true;
            use_relays = false;
          };

          # Logging
          logging = {
            level = "info";
            format = "text";
          };

          # Firewall rules - allow all traffic within the mesh
          firewall = {
            outbound = [
              {
                port = "any";
                proto = "any";
                host = "any";
              }
            ];
            inbound = [
              {
                port = "any";
                proto = "icmp";
                host = "any";
              }
              {
                port = "any";
                proto = "any";
                host = "any";
              }
            ];
          };
        };
      };
    };
}
