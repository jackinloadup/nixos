{ pkgs, config, lib, ...}: let
  inherit (lib) mkEnableOption mkIf types mkOption optional;
in {
  options.gumdrop.vpn = {
    server = {
      enable = mkEnableOption "Make server";
      endpoint = mkOption {
        type = types.str;
        example = "example.host.com:51820";
        descrption = "Ip address on network";
      };
    };
    client = {
      enable = mkEnableOption "Make Client";
      ip = mkOption {
        type = types.str;
        example = "10.100.0.2/24";
        descrption = "Ip address on network";
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
    networking.wireguard.interfaces = {
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
          # Phone
          { # Feel free to give a meaning full name
            # Public key of the peer (not a file path).
            #publicKey = "Pk4PfIDAhuctWOBHjUu8RvLQUb8TWGQmtv+x0iDLW1E=";
            publicKey = "4bJ3FxfAWkfr8dbNWLHdh7fIcavtt/EbTKo/1q4C5Fs=";
            # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            allowedIPs = [ "10.100.0.2/32" ];
          }
          #{ # John Doe
          #  publicKey = "{john doe's public key}";
          #  allowedIPs = [ "10.100.0.3/32" ];
          #}
        ]
        ++ optional cfg.server.enable [
        ]
        ++ optional cfg.client.enable [
          {
            # Public key of the server (not a file path).
            publicKey = "{server public key}";

            # Forward all the traffic via VPN.
            allowedIPs = [ "0.0.0.0/0" ];
            # Or forward only particular subnets
            #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

            # Set this to the server IP and port.
            endpoint = cfg.server.endpoint; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

            # Send keepalives every 25 seconds. Important to keep NAT tables alive.
            persistentKeepalive = 25;
          }
        ];

      };
    };
  };
}
