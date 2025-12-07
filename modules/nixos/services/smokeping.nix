{ lib, config, pkgs, ... }: let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.smokeping.enable {
    services.smokeping = {
      host = "smokeping.lucasr.com";
      probeConfig = ''
        +FPing
        binary = ${config.security.wrapperDir}/fping

        +FPing6
        binary = ${config.security.wrapperDir}/fping
        protocol = 6

        +DNS
        binary = ${pkgs.dig}/bin/dig
        lookup = 10.16.1.1
        pings = 5
        step = 300
      '';
      targetConfig = ''
        probe = FPing
        menu = Top
        title = Murray Home Network Statistics
        remark = To view the network statistics, choose from one of the latency menu options in the column on the left.

        + network
        menu = Net latency
        title = Network latency (ICMP pings)

        ++ Google
        host = google.com

        ++ Spectrum
        host = rns01.charter.com

        ++ WashU
        host = anycast.ip.wustl.edu.

        ++ Amazon
        host = amazon.com

        ++ Studio
        host = 10.100.0.4

        ++ Timberlake
        host = 10.100.0.8

        ++ home-router
        host = testwifi.here

        ++ Netflix
        host = netflix.com

        + services
        menu = Service latency
        title = Service latency (DNS, HTTP)

        ++ DNS
        probe = DNS
        menu = DNS latency
        title = Service latency (DNS)

        +++ Google
        host = dns.google

        +++ Spectrum
        host = rns01.charter.com

        +++ OpenDNS
        host = resolver1.opendns.com

        +++ WashU
        lookup = wustl.edu
        host = anycast.ip.wustl.edu.

        +++ CloudFlare
        host = one.one.one.one

        +++ home-router
        host = testwifi.here

        ++ HTTP
        menu = HTTP latency
        title = Service latency (HTTP)

        +++ Google
        host = google.com

        +++ OpenDNS
        host = opendns.com

        +++ WashU
        host = www.wustl.edu

        +++ Amazon
        host = amazon.com

        +++ home-router
        host = testwifi.here

        +++ Netflix
        host = netflix.com
      '';
    };
  };
}
