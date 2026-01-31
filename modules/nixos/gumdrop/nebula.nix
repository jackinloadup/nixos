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
      # Option to enable routing to local LAN
      routeToLan = mkEnableOption "Route traffic between Nebula and local LAN";
      lanSubnet = mkOption {
        type = types.str;
        default = "10.16.1.0/24";
        description = "Local LAN subnet to route to";
      };
      lanInterface = mkOption {
        type = types.str;
        default = "br0";
        description = "Local LAN interface";
      };
    };
    client = {
      enable = mkEnableOption "Make Nebula client";
      ip = mkOption {
        type = types.str;
        example = "10.101.0.2/24";
        description = "IP address on the Nebula network";
      };
      routing = mkOption {
        type = types.enum [ "mesh" "lan" "all" ];
        default = "mesh";
        description = ''
          Traffic routing mode for this client:
          - "mesh": Only Nebula network connectivity, no routing through lighthouse
          - "lan": Route home LAN subnet through lighthouse (split tunnel)
          - "all": Route all traffic through lighthouse (full tunnel)
        '';
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

      # NAT configuration for routing between Nebula and LAN
      networking.nat = mkIf cfg.lighthouse.routeToLan {
        enable = true;
        internalInterfaces = [ "nebula.gumdrop" ];
        externalInterface = cfg.lighthouse.lanInterface;
      };

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

          # Unsafe routes - only for clients to route traffic via lighthouse
          # NOTE: Do NOT set this on the lighthouse itself, or it will route
          # its own LAN traffic through Nebula and lose connectivity
          tun = mkIf (cfg.client.enable && cfg.client.routing != "mesh") {
            unsafe_routes =
              if cfg.client.routing == "lan" then [
                {
                  route = cfg.lighthouse.lanSubnet;
                  via = "10.101.0.1"; # Lighthouse Nebula IP
                }
              ]
              else if cfg.client.routing == "all" then [
                # Split into two /1 routes instead of one /0 route.
                # Together these cover all IPv4 addresses, but being more
                # specific than the default route (/0), they take priority
                # while preserving the original default route. This ensures
                # the underlay connection to the lighthouse's public IP
                # remains reachable even if Nebula doesn't handle this automatically.
                {
                  route = "0.0.0.0/1";
                  via = "10.101.0.1";
                }
                {
                  route = "128.0.0.0/1";
                  via = "10.101.0.1";
                }
              ]
              else [ ];
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

      ## Add MASQUERADE rules for bidirectional NAT between Nebula and LAN
      #networking.firewall.extraCommands = mkIf cfg.lighthouse.routeToLan ''
      #  # Nebula -> LAN: MASQUERADE traffic from Nebula network going to LAN
      #  iptables -t nat -A POSTROUTING -s 10.101.0.0/24 -o ${cfg.lighthouse.lanInterface} -j MASQUERADE
      #  # LAN -> Nebula: MASQUERADE traffic from LAN going to Nebula network
      #  iptables -t nat -A POSTROUTING -s ${cfg.lighthouse.lanSubnet} -o nebula.gumdrop -j MASQUERADE
      #'';

      #networking.firewall.extraStopCommands = mkIf cfg.lighthouse.routeToLan ''
      #  iptables -t nat -D POSTROUTING -s 10.101.0.0/24 -o ${cfg.lighthouse.lanInterface} -j MASQUERADE || true
      #  iptables -t nat -D POSTROUTING -s ${cfg.lighthouse.lanSubnet} -o nebula.gumdrop -j MASQUERADE || true
      #'';
    };
}
