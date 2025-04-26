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
    #./nebula-lighthouse.nix
    ./adguard.nix
    ./murmur.nix
  ];

  config = {

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
    gumdrop.scanned-document-handling.enable = true;

    services.media-services.enable = false;

    networking.hostName = "marulk";
    networking.networkmanager.enable = mkForce false;
    networking.bridges.br0.interfaces = ["enp1s0f0"];
    networking.interfaces.br0.useDHCP = true;


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
    services.audiobookshelf = {
      enable = true;
      openFirewall = false; # handle http via nginx
    };

    services.jellyfin = {
      enable = true;
      openFirewall = false; # handle http via nginx
    };

    # tcp is handled via nginx
    networking.firewall.allowedUDPPorts = [
      1900
      7359
    ];

    services.nginx.virtualHosts."jellyfin.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://localhost:8096/";
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
        proxyPass = "http://reg.home.lucasr.com:${toString config.services.paperless.port}/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."audiobookshelf.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS challenege

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.audiobookshelf.port}/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host localhost;
        '';
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
