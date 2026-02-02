{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.hydra.enable {
    # Generate netrc and git config for HTTPS git authentication
    systemd.services.generate-nix-netrc = {
      description = "Generate nix netrc for git authentication";
      wantedBy = [ "nix-daemon.service" ];
      before = [ "nix-daemon.service" ];
      after = [ "agenix.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /etc/nix
        TOKEN=$(cat ${config.age.secrets.hydra-forgejo-token.path})

        # Netrc format for curl/nix
        cat > /etc/nix/netrc << EOF
        machine git.lucasr.com
        login forgejo
        password $TOKEN
        EOF
        chmod 600 /etc/nix/netrc

        # Git config with URL rewriting to embed token
        cat > /etc/gitconfig << EOF
        [url "https://forgejo:$TOKEN@git.lucasr.com/"]
          insteadOf = https://git.lucasr.com/
        EOF
        chmod 644 /etc/gitconfig
      '';
    };

    nix.settings.netrc-file = "/etc/nix/netrc";

    # Ensure nix-daemon can see git config
    systemd.services.nix-daemon.environment = {
      GIT_CONFIG_SYSTEM = "/etc/gitconfig";
      HOME = "/root";
    };

    nix = {
      settings.sandbox = true;
      settings.trusted-users = [ "hydra" "hydra-queue-runner" ];
      buildMachines = [
        {
          hostName = "reg.home.lucasr.com";
          system = "x86_64-linux";
          sshUser = "hydra-builder";
          sshKey = config.age.secrets.hydra-builder-ssh-key.path;
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" ];
          maxJobs = 4;
          speedFactor = 2;
        }
        {
          hostName = "zen.home.lucasr.com";
          system = "x86_64-linux";
          sshUser = "hydra-builder";
          sshKey = config.age.secrets.hydra-builder-ssh-key.path;
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" ];
          maxJobs = 8;
          speedFactor = 3;
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
      chmod 770 /var/lib/hydra/{www,queue-runner,build-logs,runcommand-logs}

      # Create gcroots directory for hydra
      mkdir -p /nix/var/nix/gcroots/hydra
      chown hydra:hydra /nix/var/nix/gcroots/hydra

      # SSH key for remote builders is managed by agenix
      mkdir -p /var/lib/hydra/queue-runner/.ssh
      chown -R hydra-queue-runner:hydra /var/lib/hydra/queue-runner/.ssh
      chmod 700 /var/lib/hydra/queue-runner/.ssh

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
      hydraURL = "https://hydra.home.lucasr.com";
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

        # SECURITY NOTE: IFD allows derivations to be built during evaluation.
        # This is required for stylix/base16 color schemes but can be a security
        # risk if evaluating untrusted flakes. Only enable for trusted repos.
        allow-import-from-derivation = true
      '';
    };

    services.nginx.virtualHosts."hydra.home.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
