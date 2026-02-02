{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.services.mail-relay;
in
{
  options.services.mail-relay = {
    enable = mkEnableOption "local Postfix relay to Gmail";

    smtpUser = mkOption {
      type = types.str;
      description = "Gmail address for SMTP authentication";
      example = "myemail@gmail.com";
    };

    smtpPasswordFile = mkOption {
      type = types.path;
      description = "Path to file containing Gmail app password";
      example = "/run/secrets/gmail-smtp-password";
    };

    fromDomain = mkOption {
      type = types.str;
      default = "lucasr.com";
      description = "Domain to use for From addresses";
    };
  };

  config = mkIf cfg.enable {
    services.postfix = {
      enable = true;

      settings.main = {
        myhostname = "${config.networking.hostName}.home.${cfg.fromDomain}";
        mydomain = cfg.fromDomain;
        myorigin = cfg.fromDomain;
        # Relay through Gmail
        relayhost = [ "[smtp.gmail.com]:587" ];

        # SASL authentication for Gmail
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_tls_security_options = "noanonymous";

        # TLS encryption
        smtp_tls_security_level = "encrypt";
        smtp_tls_CAfile = "/etc/ssl/certs/ca-certificates.crt";

        # Only accept local connections
        inet_interfaces = "localhost";
        mynetworks = [ "127.0.0.0/8" "[::1]/128" ];

        # Disable local delivery attempts for external addresses
        mydestination = "";
      };
    };

    # Systemd service to set up SASL credentials before Postfix starts
    systemd.services.postfix-sasl-setup = {
      description = "Setup Postfix SASL credentials for Gmail relay";
      after = [ "agenix.service" ];
      before = [ "postfix.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail
        mkdir -p /etc/postfix
        echo "[smtp.gmail.com]:587 ${cfg.smtpUser}:$(cat ${cfg.smtpPasswordFile})" > /etc/postfix/sasl_passwd
        chmod 600 /etc/postfix/sasl_passwd
        ${pkgs.postfix}/bin/postmap /etc/postfix/sasl_passwd
        rm /etc/postfix/sasl_passwd  # Remove plaintext, keep .db
      '';
    };

    # Ensure Postfix restarts if credentials change
    systemd.services.postfix.restartTriggers = [ cfg.smtpPasswordFile ];

    # Mail aliases for system accounts
    environment.etc."aliases".text = ''
      root: ${cfg.smtpUser}
      postmaster: ${cfg.smtpUser}
    '';
  };
}
