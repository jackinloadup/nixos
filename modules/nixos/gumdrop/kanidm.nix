{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.gumdrop.kanidm;

  # OAuth2 client icons
  icons = {
    nextcloud = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/nextcloud/server/master/core/img/logo/logo.svg";
      hash = "sha256-e3YiiNW3v01dP9g8XKrBeS3FJfGqtLcJaMufuaEThn8=";
    };
    jellyfin = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/jellyfin/jellyfin-ux/master/branding/SVG/icon-transparent.svg";
      hash = "sha256-gXwltHRCsZIlBEj+SM1fJl/pGDvHWqEgMLvjNUlSVdE=";
    };
    immich = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/immich-app/immich/main/docs/static/img/immich-logo.svg";
      hash = "sha256-36XvcE0HhUkUMGwMIkFzvaJxD4/A3/6314aQ9Y+YEaY=";
    };
    paperless = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/main/resources/logo/web/svg/square.svg";
      hash = "sha256-yr3c21EUv/pYhfS0N/efeyZUwgLEBaW6betIU+1yLyg=";
    };
    grafana = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/grafana/grafana/main/public/img/grafana_icon.svg";
      hash = "sha256-UIBtWmV3nnn3RjmFcOD8Mi1d5V4Z8L6HonWWPwlHu14=";
    };
    open-webui = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/open-webui/open-webui/main/static/favicon.png";
      hash = "sha256-RD5ESYTA3zDvpdZJzJwbxzqBqgG57I518cIt0kXIlzI=";
    };
    audiobookshelf = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/advplyr/audiobookshelf/master/client/static/Logo.png";
      hash = "sha256-JGPk+WNT1C4DC4lSMb0K0YmAMT5LvmSOeO0QRzkc7Lk=";
    };
  };
in
{
  options.gumdrop.kanidm = {
    enable = mkEnableOption "Kanidm identity provider";
    domain = mkOption {
      type = types.str;
      default = "auth.lucasr.com";
    };
  };

  config = mkIf cfg.enable {
    services.kanidm = {
      enableServer = true;
      enableClient = true;
      # Required for adminPasswordFile, idmAdminPasswordFile, and basicSecretFile
      package = pkgs.kanidm.withSecretProvisioning;

      serverSettings = {
        domain = cfg.domain;
        origin = "https://${cfg.domain}";
        bindaddress = "127.0.0.1:8443";
        ldapbindaddress = "127.0.0.1:636";
        trust_x_forward_for = true;
        tls_chain = "/var/lib/acme/${cfg.domain}/fullchain.pem";
        tls_key = "/var/lib/acme/${cfg.domain}/key.pem";
      };

      clientSettings.uri = "https://${cfg.domain}";

      provision = {
        enable = true;
        adminPasswordFile = config.age.secrets.kanidm-admin-password.path;
        idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;

        groups = {
          "homelab.admins" = { };
          "nextcloud.users" = { };
          "jellyfin.users" = { };
          "immich.users" = { };
          "paperless.users" = { };
          "grafana.users" = { };
          "open-webui.users" = { };
          "audiobookshelf.users" = { };
        };

        persons = {
          lriutzel = {
            displayName = "Lucas Riutzel";
            mailAddresses = [ "lriutzel@gmail.com" ];
            groups = [ "homelab.admins" "nextcloud.users" "jellyfin.users" "immich.users" "paperless.users" "grafana.users" "open-webui.users" "audiobookshelf.users" ];
          };
          criutzel = {
            displayName = "Christine Riutzel";
            mailAddresses = [ "christinekershaw@gmail.com" ];
            groups = [ "nextcloud.users" "jellyfin.users" "immich.users" "open-webui.users" "audiobookshelf.users" ];
          };
        };

        systems.oauth2 = {
          nextcloud = {
            displayName = "Nextcloud";
            originUrl = "https://nextcloud.lucasr.com/apps/user_oidc/code";
            originLanding = "https://nextcloud.lucasr.com";
            basicSecretFile = config.age.secrets.kanidm-oidc-nextcloud.path;
            # PKCE is enabled by default in Kanidm
            preferShortUsername = true;
            scopeMaps."nextcloud.users" = [ "openid" "profile" "email" ];
            imageFile = icons.nextcloud;
          };
          jellyfin = {
            displayName = "Jellyfin";
            originUrl = "https://jellyfin.home.lucasr.com/sso/OID/redirect/kanidm";
            originLanding = "https://jellyfin.home.lucasr.com";
            basicSecretFile = config.age.secrets.kanidm-oidc-jellyfin.path;
            preferShortUsername = true;
            # Allow localhost redirects since Jellyfin sends internal URL
            enableLocalhostRedirects = true;
            # Include 'groups' scope for role-based access in Jellyfin
            scopeMaps."jellyfin.users" = [ "openid" "profile" "email" "groups" ];
            scopeMaps."homelab.admins" = [ "openid" "profile" "email" "groups" ];
            imageFile = icons.jellyfin;
          };
          immich = {
            displayName = "Immich";
            originUrl = "https://immich.lucasr.com/auth/login";
            originLanding = "https://immich.lucasr.com";
            # Use public client (PKCE only, no secret) - Immich supports PKCE
            public = true;
            preferShortUsername = true;
            # Mobile app redirect
            enableLocalhostRedirects = true;
            scopeMaps."immich.users" = [ "openid" "profile" "email" ];
            imageFile = icons.immich;
          };
          paperless = {
            displayName = "Paperless";
            originUrl = "https://paperless.home.lucasr.com/accounts/oidc/kanidm/login/callback/";
            originLanding = "https://paperless.home.lucasr.com";
            basicSecretFile = config.age.secrets.kanidm-oidc-paperless.path;
            # Paperless/django-allauth doesn't support PKCE
            allowInsecureClientDisablePkce = true;
            preferShortUsername = true;
            scopeMaps."paperless.users" = [ "openid" "profile" "email" ];
            imageFile = icons.paperless;
          };
          grafana = {
            displayName = "Grafana";
            originUrl = "https://grafana.home.lucasr.com/login/generic_oauth";
            originLanding = "https://grafana.home.lucasr.com";
            basicSecretFile = config.age.secrets.kanidm-oidc-grafana.path;
            preferShortUsername = true;
            scopeMaps."grafana.users" = [ "openid" "profile" "email" ];
            scopeMaps."homelab.admins" = [ "openid" "profile" "email" ];
            imageFile = icons.grafana;
          };
          open-webui = {
            displayName = "Open WebUI";
            originUrl = "https://chat.lucasr.com/oauth/oidc/callback";
            originLanding = "https://chat.lucasr.com";
            basicSecretFile = config.age.secrets.kanidm-oidc-open-webui.path;
            preferShortUsername = true;
            scopeMaps."open-webui.users" = [ "openid" "profile" "email" ];
            imageFile = icons.open-webui;
          };
          audiobookshelf = {
            displayName = "Audiobookshelf";
            originUrl = "https://audiobookshelf.lucasr.com/audiobookshelf/auth/openid/callback";
            originLanding = "https://audiobookshelf.lucasr.com/audiobookshelf";
            basicSecretFile = config.age.secrets.kanidm-oidc-audiobookshelf.path;
            preferShortUsername = true;
            # Mobile app support
            enableLocalhostRedirects = true;
            scopeMaps."audiobookshelf.users" = [ "openid" "profile" "email" ];
            imageFile = icons.audiobookshelf;
          };
        };
      };
    };

    # Nginx reverse proxy
    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "https://127.0.0.1:8443";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # Rewrite localhost redirects for Jellyfin SSO
          proxy_redirect http://127.0.0.1:8096/ https://jellyfin.home.lucasr.com/;
          proxy_redirect https://127.0.0.1:8096/ https://jellyfin.home.lucasr.com/;
        '';
      };
    };

    # ACME certificate access for Kanidm
    security.acme.certs.${cfg.domain} = {
      group = "kanidm";
      reloadServices = [ "kanidm" ];
    };

    # Allow nginx to read the kanidm certificate
    users.users.nginx.extraGroups = [ "kanidm" ];
  };
}
