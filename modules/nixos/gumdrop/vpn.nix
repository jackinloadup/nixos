{ pkgs, config, lib, ...}: let
  inherit (lib) mkEnableOption mkIf types mkOption optional;
in {
  # Makes a hub and spoke vpn
  options.gumdrop.vpn = {
    server = {
      enable = mkEnableOption "Make server";
      endpoint = mkOption {
        type = types.str;
        example = "example.host.com:51820";
        description = "Ip address on network";
      };
    };
    client = {
      enable = mkEnableOption "Make Client";
      ip = mkOption {
        type = types.str;
        example = "10.100.0.2/32";
        description = "Ip address on network";
      };
    };
  };
  config = let
    cfg = config.gumdrop.vpn;
  in {
    # enable NAT
    networking.nat = mkIf cfg.server.enable {
      enable = true;
      internalInterfaces = [ "wg0" ];
      externalInterface = "br0";
    };

    networking.firewall = {
      allowedTCPPorts = mkIf cfg.server.enable [ 53 ];
      allowedUDPPorts = [ 51820 ]
        ++ optional cfg.server.enable [ 53 ];
    };

    networking.wireguard.enable = cfg.server.enable || cfg.client.enable;
    networking.wireguard.interfaces = {}
      // mkIf cfg.server.enable {
        # "wg0" is the network interface name. You can name the interface arbitrarily.
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [ "10.100.0.1/24" ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = 51820;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
          '';

          peers = [
            # List of allowed peers.
            { # Feel free to give a meaning full name
              name = "lucas-phone";
              # Public key of the peer (not a file path).
              publicKey = "4bJ3FxfAWkfr8dbNWLHdh7fIcavtt/EbTKo/1q4C5Fs=";
              # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
              allowedIPs = [ "10.100.0.2/32" ];
            }
            {
              name = "riko";
              publicKey = "hMalIs+gw/ooiFVjHBzysS6Wn1ZTC9AOKnSCyOEvVQc=";
              allowedIPs = [ "10.100.0.3/32" ];
            }
            {
              name = "lyza";
              publicKey = "439vHIw45W3VpVm1OllB6QN85VSUnIKT3RGWzRuzLSE=";
              allowedIPs = [ "10.100.0.4/32" ];
            }
            {
              name = "reg";
              publicKey = "ycZ424QpGCSIVswLUk2EweH+Z7sTc33dH0B0AER4pgc=";
              allowedIPs = [ "10.100.0.11/32" ];
            }
          ];

        };
      }
      // mkIf cfg.client.enable {
        # "wg0" is the network interface name. You can name the interface arbitrarily.
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [ cfg.client.ip ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = 51820;

          peers = [
            {
              name = "marulk";
              endpoint = "home.lucasr.com:51820";
              dynamicEndpointRefreshSeconds = 5;
              publicKey = "KrWVR+VV04OOmt63FOeqx9UKE4en20lDl6pGieLQSj0=";
              allowedIPs = [ "10.100.0.0/24" ];
            }
          ];
        };
      };

    services.dnsmasq = mkIf cfg.server.enable {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        bind-interfaces = true;
        interface = "wg0";
        listen-address = "10.100.0.1";
        domain = "home.lucasr.com";
        expand-hosts = true;
        address = [
          "/marulk/10.100.0.1"
          "/lucas-phone/10.100.0.2"
          "/riko/10.100.0.3"
          "/lyza/10.100.0.4"
          "/reg/10.100.0.11"
        ];
        #};
      };
    };
  };
}
