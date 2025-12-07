{lib, config, ...}: let
  inherit (lib) mkIf;
  inherit (builtins) replaceStrings;
  cfg = config.services.vaultwarden;
  vaultHost = replaceStrings ["https://"] [""] cfg.config.DOMAIN;
in {
  config = mkIf cfg.enable {
    services = {
      vaultwarden = {
        backupDir = "/var/lib/vaultwarden";
        #environmentFile = secrets;
        config = {
          SIGNUPS_ALLOWED = false;
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          ROCKET_LOG = "critical";
      #    PASSWORD_ITERATIONS = 600000;

          SMTP_HOST = "127.0.0.1";
          SMTP_PORT = 25;
          SMTP_SSL = false;

          SMTP_FROM = "admin@${vaultHost}";
          SMTP_FROM_NAME = "vaultwarden server";
        };
      };

      nginx.virtualHosts."${vaultHost}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use DNS Challenege

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.config.ROCKET_PORT}/";
          proxyWebsockets = true;
        };
      };
  };
}
