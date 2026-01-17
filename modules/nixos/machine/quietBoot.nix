{ lib
, config
, ...
}:
let
  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (!config.boot.initrd.verbose) {
    boot = {
      # heard on matrix that timeout should be able to be 0 and still
      # be interupted via firmware buffered input. Got it to work. Pressed
      # delete repeatedly and it stopped the boot.
      #
      # Placing at 10 seconds for all machines at the moment
      loader.timeout = mkDefault 10;
      # Quiet durring boot
      #initrd.verbose = false;

      # 0 = EMERG
      # 1 = ALERT
      # 2 = CRIT
      # 3 = ERR
      # 4 = WARNING - default in the majority of linux distributions.
      #               This level it’s used to display warnings or messages about non imminent errors
      # 5 = NOTICE
      # 6 = INFO
      # 7 = DEBUG
      consoleLogLevel = mkDefault 4;
      # zero didn't remove tty on shutdown

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

      plymouth = {
        enable = mkDefault true;
        theme = "stylix-spinfinity";
        #theme = mkDefault "colorful";

        #themePackages = [ pkgs.adi1090x-plymouth-themes ];
        # I thought this might be delaying the boot but after
        # going back to basic it was pretty much the same
        #theme = "deus_ex";
        #theme = mkDefault "colorful";
        # spaces are underscore
        # abstract-rings
        # blockchain
        # black-hud "turning on"
        # cross-hud "turning off"
        # connect
        # cross-hud
        # Deus Ex
        # Hexagon Dots Alt
        # Hexa Retro # both might like
        # rings
        # Seal 3
      };
    };
  };
}
