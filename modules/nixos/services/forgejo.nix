{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.services.forgejo;
in
{
  config = mkIf cfg.enable {
    services.forgejo = {
      database.type = "postgres";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = "git.lucasr.com";
          ROOT_URL = "https://git.lucasr.com/";
          HTTP_PORT = 3002;
          SSH_DOMAIN = "git.lucasr.com";
          SSH_PORT = 2222;
          START_SSH_SERVER = true;
        };
        service = {
          DISABLE_REGISTRATION = false;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
        };
        session.COOKIE_SECURE = true;
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
        # Enable OAuth2 authentication with auto-registration
        oauth2 = {
          ENABLED = true;
          ENABLE_AUTO_REGISTRATION = true;
        };
      };
    };

    # Forgejo Actions runner
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        name = "marulk-runner";
        url = "https://git.lucasr.com";
        tokenFile = config.age.secrets.forgejo-runner-token.path;
        labels = [
          "ubuntu-latest:docker://node:18-bookworm"
          "nixos:host"
        ];
      };
    };

    # Podman for Actions runner container support
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Configure Kanidm OAuth2 provider after Forgejo starts
    systemd.services.forgejo-oauth-setup = {
      description = "Configure Forgejo Kanidm OAuth2 provider";
      after = [ "forgejo.service" ];
      wants = [ "forgejo.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package pkgs.gawk pkgs.gnugrep ];
      environment = {
        FORGEJO_WORK_DIR = cfg.stateDir;
        FORGEJO_CUSTOM = "${cfg.stateDir}/custom";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "forgejo";
        Group = "forgejo";
        WorkingDirectory = cfg.stateDir;
        RemainAfterExit = true;
      };
      script = let
        configFile = "${cfg.stateDir}/custom/conf/app.ini";
      in ''
        # Wait for Forgejo to be ready
        sleep 5

        # Check if Kanidm auth source already exists
        if forgejo --config ${configFile} admin auth list | grep -q "kanidm"; then
          echo "Kanidm OAuth2 source already exists, updating..."
          AUTH_ID=$(forgejo --config ${configFile} admin auth list | grep kanidm | awk '{print $1}')
          forgejo --config ${configFile} admin auth update-oauth --id "$AUTH_ID" \
            --name kanidm \
            --provider openidConnect \
            --key forgejo \
            --secret "$(cat ${config.age.secrets.forgejo-oidc-secret.path})" \
            --auto-discover-url "https://auth.lucasr.com/oauth2/openid/forgejo/.well-known/openid-configuration" \
            --skip-local-2fa \
            --scopes "openid profile email"
        else
          echo "Creating Kanidm OAuth2 source..."
          forgejo --config ${configFile} admin auth add-oauth \
            --name kanidm \
            --provider openidConnect \
            --key forgejo \
            --secret "$(cat ${config.age.secrets.forgejo-oidc-secret.path})" \
            --auto-discover-url "https://auth.lucasr.com/oauth2/openid/forgejo/.well-known/openid-configuration" \
            --skip-local-2fa \
            --scopes "openid profile email"
        fi
      '';
    };

    # Open firewall for Forgejo SSH
    networking.firewall.allowedTCPPorts = [ 2222 ];

    services.nginx.virtualHosts."git.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3002";
        proxyWebsockets = true;
      };
      # Auto-redirect login to Kanidm SSO
      locations."= /user/login" = {
        return = "302 /user/oauth2/kanidm";
      };
    };
  };
}
