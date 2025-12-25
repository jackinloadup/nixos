{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types literalExpression;
  cfg = config.services.rtl_433;
  configFile = pkgs.writeText "rtl_433.conf" cfg.configText;
in
{
  options.services.rtl_433 = {
    enable = mkEnableOption "Enable rtl_433 services";
    package = mkOption {
      type = types.package;
      default = pkgs.rtl_433;
      defaultText = literalExpression "pkgs.rtl_433";
      description = lib.mdDoc ''
        The package used for the rtl_433 daemon.
      '';
    };
    configText = mkOption {
      type = types.lines;
      default = ''
        output json
        report_meta time:utc
        frequency   433.92M
        frequency   915M
        convert     si
        hop_interval  60
      '';
      description = ''
        Configuration for rtl_433. For all options see the
        [example config](https://github.com/merbanan/rtl_433/blob/master/conf/rtl_433.example.conf).
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.users.rtl_433 = {
      name = "rtl_433";
      group = "rtl_433";
      extraGroups = [ "plugdev" ];
      uid = 20001; # should be config.ids.uids.rtl_433;
      description = "rtl_444 daemon user";
      isSystemUser = true;
    };
    users.groups.rtl_433.gid = 20001; # should be config.ids.gids.rtl_433;

    systemd.services.rtl_433 = {
      description = "rtl_433 server daemon";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      startLimitIntervalSec = 60;
      startLimitBurst = 3;
      serviceConfig = {
        User = "rtl_433";
        Group = "rtl_433";
        ExecStart = "${cfg.package}/bin/rtl_433 -F log -v -c ${configFile}";
        StateDirectory = "rtl_443";
        #PrivateDevices = true;
        #DeviceAllow = "/dev/bus/usb/*";
        #PrivateTmp = true;
        #ProtectSystem = "full";
        #ProtectHome = "read-only";
        #AmbientCapabilities = "cap_ipc_lock";
        #NoNewPrivileges = true;
        #KillSignal = "SIGINT";
        TimeoutStopSec = "30s";
        Restart = "on-failure";
      };
    };
  };
}
