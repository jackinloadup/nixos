
{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  config = mkIf cfg.quietBoot {
    boot = {
      # Quiet durring boot
      initrd.verbose = false;
      consoleLogLevel = 0;
      kernelParams = [ "quiet" "udev.log_priority=3" ];
    };
  };
}
