{ pkgs, config, ...}: {
  config = {
    # enable NAT
    networking.nat = {
      enable = true;
      internalInterfaces = [ "wg0" ];
      externalInterface = "br0";
    };

    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 51820 ];
    };

    networking.wireguard.enable = true;
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
            # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            allowedIPs = [ "10.100.0.3/32" ];
          }
          #{ # John Doe
          #  publicKey = "{john doe's public key}";
          #  allowedIPs = [ "10.100.0.3/32" ];
          #}
        ];

      };
    };
  };
}
