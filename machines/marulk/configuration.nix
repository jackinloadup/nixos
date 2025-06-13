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
    services.audiobookshelf = {
      enable = true;
      openFirewall = false; # handle http via nginx
    };

    services.jellyfin = {
      enable = true;
      openFirewall = false; # handle http via nginx
    };

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
    ];

    services.nginx.virtualHosts."collabora.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."jellyfin.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://127.0.0.1:8096/";
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

    services.nginx.virtualHosts."homepage.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort }/";
        proxyWebsockets = true;
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
