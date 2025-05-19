{
  lib,
  pkgs,
  config,
  ...
}: let
inherit (lib) mkIf;
  cfg = config.services.media-services;
  subnet = "10.100.0.0/24";
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

    # places all services into a container to add another layer of security
    containers.media-services = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
#hostAddress = "10.16.100.10";
      localAddress = "10.16.1.10";
      #hostAddress6 = "fc00::1";
      #localAddress6 = "fc00::2";

      config = { config, pkgs, lib, ... }: {
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

        # download series
#        services.sonarr = {
#          enable = true;
#          group = "media";
#          user = "media";
#          dataDir = "/var/lib/sonarr";
#        };

          # download movies
        services.radarr = {
          enable = true;
          group = "media";
          user = "media";
          dataDir = "/var/lib/radarr";
        };

          # better indexer apis
        services.prowlarr = {
          enable = true;
#group = "media";
#          user = "media";
        };

#        services.jellyseerr = {
#          enable = true;
#          port = 5055;
#        };
        services.bazarr = {
          enable = true;
          user = "media";
          group = "media";
          listenPort = 6767;
        };
        services.lidarr = {
          enable = true;
          user = "media";
          group = "media";
          dataDir = "/var/lib/lidarr";
        };

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

    };
  };

    # proxy interfaces
    services.nginx.enable = true;
    services.nginx.virtualHosts = {
      "radarr.lucasr.com" = {
        extraConfig = ''
          allow ${subnet};
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://localhost:7878";
          proxyWebsockets = true;
        };
      };
      "sonarr.lucasr.com" = {
        extraConfig = ''
          allow ${subnet};
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://localhost:8989";
          proxyWebsockets = true;
        };
      };
      "prowlarr.lucasr.com" = {
        extraConfig = ''
          allow ${subnet};
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://localhost:9696";
          proxyWebsockets = true;
        };
      };
      "jellyseerr.lucasr.com" = {
        extraConfig = ''
          allow ${subnet};
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.jellyseerr.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
