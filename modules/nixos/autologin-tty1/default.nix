{ lib
, pkgs
, config
, ...
}:
# @TODO start something like agetty@tty1.service after autovt@tty1 stops
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  inherit (builtins) concatStringsSep;

  cfg = config.machine.autologin-tty1;
in
{
  imports = [ ];

  options.machine.autologin-tty1 = {
    enable = mkEnableOption "Enable auto login on tty1";
    user = mkOption {
      type = types.str;
      example = "johndoe";
      description = "User to log into";
    };
  };

  config = mkIf cfg.enable {
    systemd.targets = {
      "autologin-tty1" = {
        requires = [ "multi-user.target" ];
        after = [ "multi-user.target" ];
        unitConfig.AllowIsolate = "yes";
      };
    };

    systemd.services = {
      "autovt@tty1" = {
        enable = true;
        restartIfChanged = false;
        description = "autologin service at tty1";
        after = [ "suppress-kernel-logging.service" ];
        wantedBy = [ "autologin-tty1.target" ];
        serviceConfig = {
          ExecStart = concatStringsSep " " [
            "@${pkgs.util-linux}/sbin/agetty"
            "agetty --login-program ${pkgs.shadow}/bin/login"
            "--autologin ${cfg.user} --noclear %I $TERM"
          ];
          Restart = "no";
          Type = "idle";
        };
      };
      "suppress-kernel-logging" = {
        enable = true;
        restartIfChanged = false;
        description = "suppress kernel logging to the console";
        after = [ "multi-user.target" ];
        wantedBy = [ "autologin-tty1.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.util-linux}/sbin/dmesg -n 1";
          Type = "oneshot";
        };
      };
    };
  };
}
