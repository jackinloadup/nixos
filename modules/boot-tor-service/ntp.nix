{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption mkOrder getBin types literalExpression;
  cfg = config.boot.initrd.network.ntpd;
in {
  options.boot.initrd.network.ntpd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Enable ntpdate to ensure time is correctly set before startup of tor.

        Needed if your system doesn't utilize a RTC.
      '';
    };
    package = mkOption {
      type = types.package;
      default = pkgs.ntp;
      defaultText = literalExpression "pkgs.ntp";
      description = lib.mdDoc ''
        The package used for ntpdate.
      '';
    };
    address = mkOption {
      type = types.str;
      example = "0.north-america.pool.ntp.org";
      description = lib.mdDoc ''
        Pick one IP from https://www.ntppool.org/
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.network.postCommands = mkOrder 400 ''
      echo "ntp: starting ntpdate"
      echo "ntp   123/tcp" >> /etc/services
      echo "ntp   123/udp" >> /etc/services
      ${getBin cfg.package}/bin/ntpdate -b -u ${cfg.address}
    '';

    boot.initrd.systemd.extraBin = {
      ntpdate = "${getBin cfg.package}/bin/ntpdate";
    };
    boot.initrd.systemd.services.ntpd = {
      description = "Ntp Set Time";

      wantedBy = ["initrd.target"];
      conflicts = ["basic.target"];
      after = ["network.target" "initrd-nixos-copy-secrets.service"];

      unitConfig = {
        DefaultDependencies = false;
        StartLimitIntervalSec = "60";
        StartLimitBurst = "5";
      };

      serviceConfig = {
        Type = "oneshot";
        KillMode = "process";
        RemainAfterExit = true;
        ExecStart = "${getBin cfg.package}/bin/ntpdate -b -u ${cfg.address}";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };
  };
}
