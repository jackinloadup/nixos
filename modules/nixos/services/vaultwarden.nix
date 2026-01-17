{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.services.vaultwarden;
  #vaultHost = replaceStrings ["https://"] [""] cfg.config.DOMAIN;
in
{
  config = mkIf cfg.enable {
    services = {
      vaultwarden = {
        backupDir = "/mnt/gumdrop/backup/vaultwarden";
        configureNginx = true;
        domain = "vaultwarden.lucasr.com";
        environmentFile = config.age.secrets.vaultwarden-env.path;
        config = {
          SIGNUPS_ALLOWED = false;
          ROCKET_LOG = "critical";
          #    PASSWORD_ITERATIONS = 600000;

          SMTP_HOST = "127.0.0.1";
          SMTP_PORT = 25;
          SMTP_SSL = false;

          SMTP_FROM = "admin@vaultwarden.lucasr.com";
          SMTP_FROM_NAME = "vaultwarden server";
        };
      };

      nginx.virtualHosts."vaultwarden.lucasr.com" = {
        #forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        #locations."/" = {
        #  proxyPass = "http://127.0.0.1:${toString cfg.config.ROCKET_PORT}/";
        #  proxyWebsockets = true;
        #};
      };
    };
  };
}
