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
  config = mkIf config.services.homepage-dashboard.enable {
    services.homepage-dashboard = {
      widgets = [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];
      bookmarks = [{
        Starnes = [
          {
            "Vaultwarden" = [{
              description = "Password Store";
              href = "https://vaultwarden.starn.es";
            }];
          }
        ];
      }
      {
        Gumdrop = [
          {
            "Paperless" = [{
              description = "Document Manager";
              href = "https://paperless.home.lucasr.com/";
            }];
          }
          {
            "AdguardHome" = [{
              description = "Ad blocker";
              href = "https://dns.home.lucasr.com";
            }];
          }
          {
            "Syncthing - NAS" = [{
              description = "File Sync";
              href = "http://truenas.home.lucasr.com:20910/#";
            }];
          }
          {
            "Nextcloud" = [{
              description = "Personal files";
              href = "https://nextcloud.lucasr.com";
            }];
          }
          {
            "Home Assistant" = [{
              description = "Automate Life";
              href = "https://ha.home.lucasr.com/";
            }];
          }
          {
            "AI Chat" = [{
              description = "Chat Bot";
              href = "http://chat.lucasr.com/";
            }];
          }
          {
            "Searx" = [{
              description = "Search Engine";
              href = "http://searx.home.lucasr.com/";
            }];
          }
        ];
      }
      {
        Media = [
          {
            "Music Assistant" = [{
              description = "Music";
              href = "https://music-assistant.home.lucasr.com/";
            }];
          }
          {
            "Audiobookshelf" = [{
              description = "Audio Books";
              href = "https://audiobookshelf.lucasr.com/";
            }];
          }
          {
            "Jellyseerr" = [{
              description = "Media Finder";
              href = "http://jellyseerr.lucasr.com/";
            }];
          }
          {
            "Jellyfin" = [{
              description = "Consume Media";
              href = "https://jellyfin.home.lucasr.com";
            }];
          }
        ];
      }
      {
        Infra = [
          {
            "Modem" = [{
              description = "Netgear Cable Modem";
              href = "http://192.168.100.1/";
            }];
          }
          {
            "Router" = [{
              description = "Mikrotik Router";
              href = "http://10.16.1.1";
            }];
          }
          {
            "Printer" = [{
              description = "Brother MFC-9130CW";
              href = "http://printer.home.lucasr.com";
            }];
          }
          {
            "Truenas" = [{
              description = "Storage server";
              href = "http://truenas.home.lucasr.com";
            }];
          }
        ];
      }
      {
        Management = [
          {
            "Sabnzb" = [{
              description = "Download Content";
              href = "https://sabnzb.lucasr.com/";
            }];
          }
          {
            "radarr" = [{
              description = "Movies Manager";
              href = "https://radarr.lucasr.com/";
            }];
          }
          {
            "Sonarr" = [{
              description = "Series Manager";
              href = "https://sonarr.lucasr.com/";
            }];
          }
          {
            "prowlarr" = [{
              description = "Index api middleware";
              href = "https://prowlarr.lucasr.com/";
            }];
          }
          {
            "Bazarr" = [{
              description = "Subtitle Finder";
              href = "https://bazarr.lucasr.com/";
            }];
          }
            #{
            #  "Lidarr" = [{
            #    description = "Music Manager";
            #    href = "https://lidarr.lucasr.com/";
            #  }];
            #}
        ];
      }];
    };
  };
}
