{ pkgs, ... }:

let
  settings = import ../../settings;
in {
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
        ExecStart =  builtins.concatStringsSep " " ([
          "@${pkgs.utillinux}/sbin/agetty"
          "agetty --login-program ${pkgs.shadow}/bin/login"
          "--autologin ${settings.user.username} --noclear %I $TERM"
        ]);
        Restart = "always";
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
        ExecStart = "${pkgs.utillinux}/sbin/dmesg -n 1";
        Type = "oneshot";
      };
    };
  };
}
