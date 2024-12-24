{ pkgs, config, ...}: {
  config = {
    networking = {
      # enable NAT
      nat = {
        enable = true;
        internalInterfaces = [ "wg0" ];
        externalInterface = "br0";
      };

      firewall = {
        # Not sure why DNS port is needed here
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 51820 ];
      };

      wireguard = {
        enable = true;
        interfaces = {
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
              }
              {
                name = "reg";
                publicKey = "ycZ424QpGCSIVswLUk2EweH+Z7sTc33dH0B0AER4pgc=";
                allowedIPs = [ "10.100.0.11/32" ];
              }
            ];
          };
        };
      };
    };

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        interface = "wg0";
        listen-address = "10.100.0.1";
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
