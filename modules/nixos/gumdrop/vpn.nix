{ pkgs, config, lib, ...}: let
  inherit (lib) mkEnableOption mkIf types mkOption optionals optionalAttrs;
in {
  # Makes a hub and spoke vpn
  options.gumdrop.vpn = {
    server = {
      enable = mkEnableOption "Make server";
      endpoint = mkOption {
        type = types.str;
        example = "example.host.com:51820";
        description = "Ip address on network";
        default = "vpn.lucasr.com:51820";
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
        ++ optionals cfg.server.enable [ 53 ];
    };

    networking.wireguard.enable = cfg.server.enable || cfg.client.enable;
    networking.wireguard.interfaces = {}
      // optionalAttrs cfg.server.enable {
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
              #publicKey = "Pk4PfIDAhuctWOBHjUu8RvLQUb8TWGQmtv+x0iDLW1E=";
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
              persistentKeepalive = 25;
            }
            {
              name = "kanye";
              publicKey = "85q15pyFUBdt1UTE5BLklvy9uKknXdWVQWTge1Vy1nk=";
              allowedIPs = [ "10.100.0.5/32" ];
            }
            {
              name = "zen";
              publicKey = "5zadvDWL6pMIlqYI7dVrrAXFxVqHDRvJo6u+LQ0WpSQ=";
              allowedIPs = [ "10.100.0.6/32" ];
            }
            {
              name = "christine-phone";
              publicKey = "TkkSJLCOTB6/qoWh5hZzyZEtyswsRftFLjcTvKo1RBc=";
              allowedIPs = [ "10.100.0.7/32" ];
            }
            {
              name = "timberlake";
              publicKey = "TSIU47c//x361/fxl1fxZ3cpSWbH7G06jt/FVqfYpRM=";
              allowedIPs = [ "10.100.0.8/32" ];
            }
            {
              name = "nat";
              publicKey = "LFhXpxrDepNzAqVwcbvEpqDKlIUDaHyIG4t9mIsz6mk=";
              allowedIPs = [ "10.100.0.9/32" ];
            }
            {
              name = "christine-ipad";
              publicKey = "RHhV4nC7YrM/iTJmUda56JumWCiyVfkQ2Yc17qJI6ws=";
              allowedIPs = [ "10.100.0.10/32" ];
            }
            {
              name = "reg";
              publicKey = "ycZ424QpGCSIVswLUk2EweH+Z7sTc33dH0B0AER4pgc=";
              allowedIPs = [ "10.100.0.11/32" ];
            }
          ];

        };
        # Sean's networkk
#        wg1 = {
#          # Determines the IP address and subnet of the server's end of the tunnel interface.
#          ips = [ "10.9.0.12/24" ];
## DNS = 10.8.0.1, 10.8.1.250
#
#
#          # The port that WireGuard listens to. Must be accessible by the client.
#          listenPort = 51820;
#
#          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
#          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
#          postSetup = ''
#            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
#          '';
#
#          # This undoes the above command
#          postShutdown = ''
#            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.9.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
#          '';
#
#          peers = [
#            {
#              name = "sean-mcgee";
#              publicKey = "y//Flcqb/RQbmuDTK6aOMW+pCFVF80idEWDqPkG3tik=";
#              endpoint = "mcgee.starn.es:51820";
#              allowedIPs = [
#                "10.9.0.0/24"
#                "10.8.0.0/16"
#                "192.168.107.0/24"
#              ];
#            }
#          ];
#        };
#        wgmcgee = {
#          # Determines the IP address and subnet of the server's end of the tunnel interface.
#          ips = [ "10.9.0.13/24" ];
## DNS = 10.8.0.1, 10.8.1.250
#
#
#          # The port that WireGuard listens to. Must be accessible by the client.
#          listenPort = 51820;
#
#          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
#          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
#          postSetup = ''
#            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
#          '';
#
#          # This undoes the above command
#          postShutdown = ''
#            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.9.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
#          '';
#
#          peers = [
#            {
#              name = "sean-mcgee";
#              publicKey = "y//Flcqb/RQbmuDTK6aOMW+pCFVF80idEWDqPkG3tik=";
#              endpoint = "mcgee.starn.es:51820";
#              allowedIPs = [
#                "10.9.0.0/24"
#                "10.8.0.0/16"
#                "192.168.107.0/24"
#              ];
#            }
#          ];
#        };
      }
      // optionalAttrs cfg.client.enable {
        # "wg0" is the network interface name. You can name the interface arbitrarily.
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [ cfg.client.ip ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = 51820;
          dynamicEndpointRefreshSeconds = 5;

          peers = [
            {
              name = "marulk";
              endpoint = "home.lucasr.com:51820";
              publicKey = "KrWVR+VV04OOmt63FOeqx9UKE4en20lDl6pGieLQSj0=";
              allowedIPs = [ "10.100.0.0/24" ];
              persistentKeepalive = 25;
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
          "/marulk/10.100.0.1" # server
          "/lucas-phone/10.100.0.2"
          "/riko/10.100.0.3" # Christine's laptop
          "/lyza/10.100.0.4" # Christine's studio
          "/kanye/10.100.0.5"
          "/zen/10.100.0.6" # Christine Desktop
          "/christine-phone/10.100.0.7"
          "/timberlake/10.100.0.8"
          "/nat/10.100.0.9" # Nathan Kodi
          "/christine-ipad/10.100.0.10"
          "/reg/10.100.0.11" # Desktop
        ];
      };
    };
  };
}
