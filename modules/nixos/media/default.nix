{
  lib,
  pkgs,
  config,
  ...
}: let
inherit (lib) mkIf;
  cfg = config.services.media-services;
  allowSubnets = ''
    allow 127.0.0.1;
    allow 10.100.0.0/24;
    allow 10.16.0.0/16;
  '';
in {
  imports = [
  ];

  options = {
    services.media-services.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      example = true;
      description = ''
        Whether this machine is used as a Media Center.
      '';
    };
  };

  config = mkIf cfg.enable {

    hardware.amdgpu.opencl.enable = true;
    hardware.amdgpu.amdvlk.enable = true;
    hardware.graphics.extraPackages = [ pkgs.amf ];
    hardware.graphics.enable = true;

    #readarr
    #whisparr

    # force dir to exist
    systemd.tmpfiles.rules = [
      "d /var/lib/sabnzbd 0775 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} -"
      "d /var/lib/radarr 0775 ${config.services.radarr.user} ${config.services.radarr.group} -"
      "d /var/lib/sonarr 0775 ${config.services.sonarr.user} ${config.services.sonarr.group} -"
      "d /var/lib/lidarr 0775 ${config.services.lidarr.user} ${config.services.lidarr.group} -"
      "d /var/lib/bazarr 0775 ${config.services.bazarr.user} ${config.services.bazarr.group} -"
      "d /var/lib/prowlarr 0775 root root -"
      "d /var/lib/jellyseer 0775 ${config.services.jellyfin.user} ${config.services.jellyfin.group} -"
    ];

    # places all services into a container to add another layer of security
    #    containers.media-services = {
    #      autoStart = true;
    #      privateNetwork = false;
    #      #hostBridge = "br0";
    ##hostAddress = "10.16.100.10";
    #      #localAddress = "10.16.1.10";
    #      #hostAddress6 = "fc00::1";
    #      #localAddress6 = "fc00::2";
    #      bindMounts = {
    #        #"/run/autobrr.secret".hostPath = "/run/autobrr.secret";
    #        #"/var/lib/private/autobrr" = {
    #        #  hostPath = "/var/lib/autobrr";
    #        #  isReadOnly = false;
    #        #};
    #        "/var/lib/sabnzbd" = {
    #          hostPath = "/var/lib/sabnzbd";
    #          isReadOnly = false;
    #        };
    #        "/var/lib/radarr" = {
    #          hostPath = "/var/lib/radarr";
    #          isReadOnly = false;
    #        };
    #        "/var/lib/sonarr" = {
    #          hostPath = "/var/lib/sonarr";
    #          isReadOnly = false;
    #        };
    #        "/var/lib/lidarr" = {
    #          hostPath = "/var/lib/lidarr";
    #          isReadOnly = false;
    #        };
    #        "/var/lib/bazarr" = {
    #          hostPath = "/var/lib/bazarr";
    #          isReadOnly = false;
    #        };
    #        "/var/lib/prowlarr" = {
    #          hostPath = "/var/lib/prowlarr";
    #          isReadOnly = false;
    #        };
    #        "/var/lib/jellyseerr" = {
    #          hostPath = "/var/lib/jellyseerr";
    #          isReadOnly = false;
    #        };
    #        "/mnt/gumdrop/media" = {
    #          hostPath = "/mnt/gumdrop/media";
    #          isReadOnly = false;
    #        };
    #        #"/var/lib/qbittorrent" = {
    #        #  hostPath = "/var/lib/qbittorrent";
    #        #  isReadOnly = false;
    #        #};
    #        #"/mnt/Media" = {
    #        #  hostPath = "/mnt/Media";
    #        #  isReadOnly = false;
    #        #};
    #      };
    #
    #      config = { config, pkgs, lib, ... }: {
        # Set-up media group
        users.users.media = {
          isNormalUser = false;
          isSystemUser = true;
          group = "media";
        };
        # Set-up media group
        users.groups.media = { };

        networking.firewall.interfaces.wg0.allowedTCPPorts = [
          7878
          8989
        ];

        services.sabnzbd = { # nzb downloader
          enable = true;
          group = "media";
          user = "media";
        };

        services.sonarr = { # Series
          enable = true;
          group = "media";
          user = "media";
          #  dataDir = "/var/lib/sonarr";
        };

        services.radarr = { # Movies
          enable = true;
          group = "media";
          user = "media";
          #dataDir = "/var/lib/radarr";
        };

          # better indexer apis
        services.prowlarr = { # Index proxy
          enable = true;
#group = "media";
#          user = "media";
        };

        services.jellyseerr = { # User Friendly media request ui for external users
          enable = true;
          port = 5055;
        };
        services.bazarr = { # Subtitles
          enable = true;
          user = "media";
          group = "media";
          listenPort = 6767;
        };
        #        services.lidarr = { # Music
        #          enable = true;
        #          user = "media";
        #          group = "media";
        #          #dataDir = "/var/lib/lidarr";
        #        };

        #permown."/media/arr" = {
        #  owner = "media";
        #  group = "media";
        #  directory-mode = "770";
        #  file-mode = "770";
        #};

        #(lib.mkIf cfg.jackett.enable {
#          services.jackett = {
#            enable = true;
#          };
#
#          # Jackett wants to eat *all* my RAM if left to its own devices
#          systemd.services.jackett = {
#            serviceConfig = {
#              MemoryHigh = "15%";
#              MemoryMax = "25%";
#            };
#          };

        #});
#      };
#    };

    # proxy interfaces
    services.nginx.enable = true;
    services.nginx.virtualHosts = {
      "sabnzb.lucasr.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        extraConfig = ''
          ${allowSubnets}
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080/";
          proxyWebsockets = true;
        };
      };
      "radarr.lucasr.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        extraConfig = ''
          ${allowSubnets}
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.radarr.settings.server.port }/";
          proxyWebsockets = true;
        };
      };
      "sonarr.lucasr.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        extraConfig = ''
          ${allowSubnets}
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port }/";
          proxyWebsockets = true;
        };
      };
      "prowlarr.lucasr.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        extraConfig = ''
          ${allowSubnets}
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port }/";
          proxyWebsockets = true;
        };
      };
      "jellyseerr.lucasr.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        extraConfig = ''
          ${allowSubnets}
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.jellyseerr.port}";
          proxyWebsockets = true;
        };
      };
      "lidarr.lucasr.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        extraConfig = ''
          ${allowSubnets}
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.lidarr.settings.server.port }";
          proxyWebsockets = true;
        };
      };
      "bazarr.lucasr.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        extraConfig = ''
          ${allowSubnets}
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort }";
          proxyWebsockets = true;
        };
      };
    };

    #systemd.services."container@arr-servers" = {
    #  bindsTo = ["mnt-Home.mount" "mnt-Media.mount"];
    #  after = ["mnt-Home.mount" "mnt-Media.mount"];
    #  unitConfig = {
    #    ConditionPathExists = "/run/autobrr.secret";
    #  };
    #};
  };
}
