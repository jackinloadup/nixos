{
  lib,
  pkgs,
  config,
  ...
}:
# look into using hail to deploy from hydra
let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.hydra.enable {
    nix = {
      settings.sandbox = true;
      nrBuildUsers = config.nix.settings.max-jobs;
      buildMachines = [
        {
          hostName = "localhost";
          system = "x86_64-linux";
          supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
          maxJobs = 8;
        }
      ];
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["hydra"];
      ensureUsers = [
        {
          name = "hydra";
          ensurePermissions."DATABASE \"hydra\"" = "ALL PRIVILEGES";
        }
      ];
    };

    services.postgresqlBackup.databases = ["hydra"];

    services.hydra = {
      hydraURL = "http://localhost:3000"; # externally visible URL
      notificationSender = "hydra@localhost"; # e-mail of hydra service
      listenHost = "localhost";
      # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
      buildMachinesFiles = [];
      # you will probably also want, otherwise *everything* will be built from scratch
      useSubstitutes = true;
      minimumDiskFree = 20;
      minimumDiskFreeEvaluator = 20;
    };
  };
}
