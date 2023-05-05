{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.machine;
in {
  options.machine.quietBoot = mkEnableOption "Hide boot log from tui/gui";

  config = mkIf cfg.quietBoot {
    boot = {
      # heard on matrix that timeout should be able to be 0 and still
      # be interupted via firmware buffered input. I didn't experience this yet.
      # setting to 1 to allow capture for now
      loader.timeout = mkDefault 1;
      # Quiet durring boot
      initrd.verbose = false;

      # 0 = EMERG
      # 1 = ALERT
      # 2 = CRIT
      # 3 = ERR
      # 4 = WARNING - default in the majority of linux distributions.
      #               This level it’s used to display warnings or messages about non imminent errors
      # 5 = NOTICE
      # 6 = INFO
      # 7 = DEBUG
      consoleLogLevel = 4;

      # Parameters prefixed with "rd." will be read when systemd-udevd is used in an initrd,
      # those without will be processed both in the initrd and on the host.
      kernelParams = [
        "quiet"
        #"vga=current" # maybe should be using gfxplayload or gfxmode
        #"i915.fastboot=1"
        #"loglevel=3" # controled with consoleLogLevel above
        "udev.log_level=3"
        "udev.log_priority=3"
        "vt.global_cursor_default=0" # disable the frame buffer console cursor

        # auto only shows messages about failures if there is a significant delay in boot
        "systemd.show_status=auto"
        #"rd.systemd.show_status=auto"
      ];
    };
  };
}
