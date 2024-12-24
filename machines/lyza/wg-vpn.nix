
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
        ips = [ "10.100.0.4/24" ];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = 51820;


        peers = [
          # List of allowed peers.
          {
            name = "marulk";
            endpoint = "home.lucasr.com:51820";
            dynamicEndpointRefreshSeconds = 5;
            publicKey = "KrWVR+VV04OOmt63FOeqx9UKE4en20lDl6pGieLQSj0=";
            allowedIPs = [ "10.16.1.0/24" "10.100.0.0/24" ];
            persistentKeepalive = 30;  # seconds; Due to being behind NAT
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
