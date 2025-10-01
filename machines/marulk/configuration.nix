{
  self,
  flake,
  pkgs,
  lib,
  config,
  ...
}:
# Machine runs DNS and home-assistant vm
let
  inherit (lib) mkForce mkDefault;
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
    ./homepage.nix
    #./nebula-lighthouse.nix
    ./adguard.nix
    ./murmur.nix
    ./immich.nix
    ./frigate.nix
  ];

  config = {

    nixpkgs.config.allowUnfree = true;

    boot.initrd.verbose = true;

    machine = {
      users = [ "lriutzel" ];
      sizeTarget = 1;
      home-assistant = true;
      tui = true;
    };

    gumdrop.vpn.server.enable = true;
    gumdrop.storageServer.enable = true;
    gumdrop.storageServer.media = true;
    gumdrop.printerScanner = true;

    gumdrop.scanned-document-handling.enable = true;

    services.media-services.enable = true;
    services.smokeping = {
      enable = true;
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


    #services.vaultwarden = {
    #  enable = true;
    #  backupDir = "/var/lib/vaultwarden";
    #  #environmentFile = secrets;
    #  config = {
    #    DOMAIN = "https://bitwarden.lucasr.com";
    #    SIGNUPS_ALLOWED = false;
    #    ROCKET_ADDRESS = "127.0.0.1";
    #    ROCKET_PORT = 8222;
    #    ROCKET_LOG = "critical";

    #    SMTP_HOST = "127.0.0.1";
    #    SMTP_PORT = 25;
    #    SMTP_SSL = false;

    #    SMTP_FROM = "admin@bitwarden.lucasr.com";
    #    SMTP_FROM_NAME = "example.com Bitwarden server";
    #  }
    #};


    networking.hostName = "marulk";
    #networking.useNetworkd = true;
    systemd.network.enable = true;

    systemd.network.wait-online.enable = true;
    #systemd.network.wait-online.anyInterface = true;
    systemd.network.wait-online.extraArgs = [
      "--interface=br0"
      "--ipv4"
    ];
    #systemd.network.wait-online.ignoredInterfaces = [
    #  "wg0"
    #  "br0"
    #];

    networking.networkmanager.enable = mkForce false;
    networking.bridges.br0.interfaces = ["enp1s0f0"];
    networking.interfaces.br0.useDHCP = true;

    # because we are the dns, force upstream
#   networking.resolvconf.extraConfig = ''
#     name_servers 10.16.1.1
#   '';

    networking.dhcpcd = {
      #wait = "ipv4";
      persistent = true;
    };

    #networking.nat = {
    #  enable = true;
    #  externalInterface = "enp1s0";
    #  internalInterfaces = ["virbr0"];
    #  internalIPs = [
    #    "192.168.122.0/24"
    #  ];
    #  forwardPorts = [
    #    {
    #      destination = "192.168.122.182:1883";
    #      proto = "tcp";
    #      sourcePort = 1883;
    #    }
    #    {
    #      destination = "192.168.122.182:8123";
    #      proto = "tcp";
    #      sourcePort = 8123;
    #    }
    #  ];
    #};

    services.collabora-online = {
      enable = true;
      port = 9980; # default
      settings = {
        # Rely on reverse proxy for SSL
        ssl = {
          enable = false;
          termination = true;
        };

        # Listen on loopback interface only, and accept requests from ::1
        net = {
          listen = "loopback";
          post_allow.host = ["::1"];
        };

        # Restrict loading documents from WOPI Host nextcloud.example.com
        storage.wopi = {
          "@allow" = true;
          host = ["nextcloud.lucasr.com"];
        };

        # Set FQDN of server
        server_name = "collabora.lucasr.com";
      };
    };

    systemd.services.nextcloud-config-collabora = let
      inherit (config.services.nextcloud) occ;

      wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
      public_wopi_url = "https://collabora.lucasr.com";
      wopi_allowlist = lib.concatStringsSep "," [
        "127.0.0.1"
        "::1"
        "10.16.1.0/24" # pretty sure these two are needed
        "10.100.0.0/24"
      ];
    in {
      wantedBy = ["multi-user.target"];
      after = ["nextcloud-setup.service" "coolwsd.service"];
      requires = ["coolwsd.service"];
      script = ''
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
        ${occ}/bin/nextcloud-occ richdocuments:setup
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    # tcp is handled via nginx
    networking.firewall.allowedUDPPorts = [
      1900
      7359
      #1984 #go2rtc - now nginx proxy
      8555 # Frigate webrtc
      8554 # Frigate rtsp
      8097 # music assistant stream
    ];
    networking.firewall.allowedTCPPorts = [
      #1984 # go2rtc - now nginx proxy
      8555 # Frigate webrtc
      8554 # Frigate rtsp
      8097 # music assistant stream
    ];

    #systemd.services.nginx.serviceConfig.ReadWritePaths = [
    #  "/var/spool/nginx/logs/"
    #];
    #systemd.tmpfiles.rules = [
    #  "d /var/spool/nginx/logs 0755 nginx nginx"
    #];

     services.nginx.commonHttpConfig = ''
          log_format vhost '$host $remote_addr - $remote_user '
           '[$time_local] "$request" $status '
           '$body_bytes_sent "$http_referer" '
           '"$http_user_agent"';
          error_log stderr;
          access_log syslog:server=unix:/dev/log vhost;

        '';

    services.nginx.virtualHosts."collabora.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."ha.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://homeassistant.home.lucasr.com:8123/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."chat.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        #proxyPass = "http://10.16.1.11:${toString config.services.open-webui.port }/";
        proxyPass = "http://reg.home.lucasr.com:11112/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."paperless.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host localhost;
        '';
      };
    };

    services.nginx.virtualHosts."homepage.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort }/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."go2rtc.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://127.0.0.1:1984/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."frigate.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege
    };

    services.nginx.virtualHosts.smokeping = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege
      serverAliases = [
        "smokeping.lucasr.com"
      ];

        #locations."/" = {
        #  proxyPass = "http://127.0.0.1:${toString config.services.smokeping.listenPort }/";
        #  proxyWebsockets = true;
        #};
    };

    services.nextcloud.enable = true;


    # wireguard-tools
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    #networking.bridges.br0.interfaces = ["enp1s0f0"];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.05"; # Did you read the comment?
  };
}
