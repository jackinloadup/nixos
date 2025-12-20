{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkOption mkOrder getBin getExe optionalString types literalExpression;
  inherit (builtins) toString;
  cfg = config.boot.initrd.network.haveged;
in
{
  options.boot.initrd.network.haveged = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Enable haveged to generate entropy.

        This allows services like tor to start quicker on some machines.
      '';
    };
    package = mkOption {
      type = types.package;
      default = pkgs.haveged;
      defaultText = literalExpression "pkgs.haveged";
      description = lib.mdDoc ''
        The package used for the haveged service.
      '';
    };
    refill_threshold = mkOption {
      type = types.int;
      default = 1024;
      description = lib.mdDoc ''
        The number of bits of available entropy beneath which
        haveged should refill the entropy pool.
      '';
    };
  };

  config = mkIf cfg.enable {
    # copy haveged to you initrd
    boot.initrd.extraUtilsCommands = mkOrder 600 ''
      # copy havaged to your initrd
      copy_bin_and_libs ${getExe cfg.package}
    '';

    boot.initrd.network.postCommands = mkOrder 200 ''
      echo "haveged: colecting entropy"
      ${getExe cfg.package} -w ${toString cfg.refill_threshold} -F &
    '';

    boot.initrd.systemd.extraBin = {
      haveged = "${getExe cfg.package}";
    };
    boot.initrd.systemd.services.haveged = {
      description = "Haveged Generate Entropy";

      wantedBy = [ "initrd.target" ];
      conflicts = [ "basic.target" ];
      after = [ "network.target" "initrd-nixos-copy-secrets.service" ];

      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "simple";
        KillMode = "process";
        ExecStart = "${getExe cfg.package} -w ${toString cfg.refill_threshold} -F";
        Restart = "on-failure";
      };
    };
  };
}
