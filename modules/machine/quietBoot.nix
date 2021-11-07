{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  options.machine.quietBoot = mkEnableOption "Hide boot log from tui/gui";

  config = mkIf cfg.quietBoot {
    boot = {
      # heard on matrix that timeout should be able to be 0 and still
      # be interupted via firmware buffered input. I didn't experience this yet.
      # setting to 1 to allow capture for now
      loader.timeout = 1;
      # Quiet durring boot
      initrd.verbose = false;
      consoleLogLevel = 0;
      kernelParams = [ "quiet" "udev.log_priority=3" ];
    };
  };
}
