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
  config = {
    services.homepage-dashboard = {
      enable = true;
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
        Bookmarks = [
          {
            "Jellyfin" = [{
              description = "";
              href = "https://jellyfin.home.lucasr.com";
            }];
          }
          {
            "AdguardHome" = [{
              description = "Ad blocker";
              href = "https://dns.home.lucasr.com";
            }];
          }
          {
            "Nextcloud" = [{
              description = "Personal files";
              href = "https://nextcloud.lucasr.com";
            }];
          }
          {
            "Audiobookshelf" = [{
              description = "Audio Books";
              href = "https://audiobookshelf.lucasr.com/";
            }];
          }
          {
            "Home Assistant" = [{
              description = "";
              href = "https://ha.home.lucasr.com/";
            }];
          }
          {
            "Chat" = [{
              description = "AI chat";
              href = "http://chat.lucasr.com:11112/";
            }];
          }];
      }
      {
        Media = [
          {
            "radarr" = [{
              description = "Movies";
              href = "http://radarr.lucasr.com:11112/";
            }];
          }
          {
            "prowlarr" = [{
              description = "Index api middleware";
              href = "http://prowlarr.lucasr.com:11112/";
            }];
          }
          {
            "Bazarr" = [{
              description = "bazaar";
              href = "http://bazarr.lucasr.com/";
            }];
          }
          {
            "Lidarr" = [{
              description = "lidarr";
              href = "http://lidarr.lucasr.com/";
            }];
          }
        ];
      }];
    };
  };
}
