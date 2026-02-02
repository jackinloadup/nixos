{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.hydra.enable {
    nix = {
      settings.sandbox = true;
      buildMachines = [
        {
          hostName = "localhost";
          system = "x86_64-linux";
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          maxJobs = 8;
        }
      ];
    };

    # PostgreSQL is required
    services.postgresql.enable = true;

    # Fix hydra-init to be idempotent (handle existing dirs/roles)
    systemd.services.hydra-init.path = [ config.services.postgresql.package ];
    systemd.services.hydra-init.preStart = lib.mkForce ''
      mkdir -p /var/lib/hydra/{www,queue-runner,build-logs,runcommand-logs}
      chown hydra:hydra /var/lib/hydra/{www,queue-runner,build-logs,runcommand-logs}

      # Create role if it doesn't exist
      if ! runuser -u postgres -- psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='hydra'" | grep -q 1; then
        runuser -u postgres -- createuser hydra
      fi

      # Create database if it doesn't exist
      if ! runuser -u postgres -- psql -tAc "SELECT 1 FROM pg_database WHERE datname='hydra'" | grep -q 1; then
        runuser -u postgres -- createdb -O hydra hydra
      fi
    '';

    services.postgresqlBackup.databases = [ "hydra" ];

    services.hydra = {
      hydraURL = "https://hydra.lucasr.com";
      notificationSender = "hydra@lucasr.com";
      listenHost = "127.0.0.1";
      port = 3001;
      buildMachinesFiles = [ ];
      useSubstitutes = true;
      minimumDiskFree = 20;
      minimumDiskFreeEvaluator = 20;
      extraConfig = ''
        store_uri = daemon?secret-key=${config.age.secrets.nix-signing-key.path}
        <git-input>
          timeout = 3600
        </git-input>
      '';
    };

    services.nginx.virtualHosts."hydra.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
      };
    };
  };
}
