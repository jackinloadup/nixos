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
    flake.self.nixosModules.server
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
;
    services.smokeping.enable = true;


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

    services.nginx.virtualHosts."searx.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = let
          port = toString config.services.searx.settings.server.port;
      in {
        proxyPass = "http://127.0.0.1:${port}/";
        proxyWebsockets = true;
      };
    };

    services.nextcloud.enable = true;


    services.searx.enable = true;

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
