{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.hydra.enable {
    nix.settings.sandbox = true;
    nix.nrBuildUsers = config.nix.settings.max-jobs;

    services.postgresql.enable = true;

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
