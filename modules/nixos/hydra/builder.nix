{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hydra.builder;

  # Public key for hydra-queue-runner from marulk
  hydraBuilderPubKey = builtins.readFile ../../../machines/marulk/hydra-builder.pub;
in
{
  options.hydra.builder = {
    enable = mkEnableOption "Hydra remote builder";

    maxJobs = mkOption {
      type = types.int;
      default = 4;
      description = "Maximum number of concurrent build jobs";
    };
  };

  config = mkIf cfg.enable {
    # Create hydra-builder user
    users.users.hydra-builder = {
      isSystemUser = true;
      group = "hydra-builder";
      home = "/var/lib/hydra-builder";
      createHome = true;
      shell = "/run/current-system/sw/bin/bash";
      openssh.authorizedKeys.keys = [ hydraBuilderPubKey ];
    };

    users.groups.hydra-builder = { };

    # Allow hydra-builder to use nix
    nix.settings.trusted-users = [ "hydra-builder" ];
  };
}
