{ lib, pkgs, config, ...}: 
with lib;
let
  cfg = config.machine.kernel;
in {
  imports = [];

  options.machine.kernel = {
    rebootAfterPanic = mkOption {
      type = with types; nullOr int;
      default = 10;
      example = 30;
      description = "How long after a panic should the kernel wait before rebooting";
    }; 
    panicOnOOM = mkEnableOption "Should kernel panic when the out-of-memory daemon is triggerd";
    panicOnFailedBoot = mkEnableOption "Should kernel panic when the boot fails";
    panicOnWarn = mkEnableOption "Should kernel panic on warn messages";
    panicOnHungTask = mkEnableOption "Should kernel panic when a hung task is found";
    panicOnHungTaskTimeout = mkOption {
      type = with types; nullOr int;
      default = 120;
      example = 300;
      description = "How long a user or kernel thread can remain in D state before kernel panic";
    };
  };

  config.boot.kernelParams = [ ]
      # Allow time for vmcore memory image to be saved
      # time require is related to memory size and storage speed.
      # 30 secs was recommended
      ++ optional (cfg.rebootAfterPanic ? true ) "panic=${toString cfg.rebootAfterPanic}" # reboot x seconds after panic
      ++ optional cfg.panicOnWarn "panic_on_warn" # panic on warn messages
      ++ optional cfg.panicOnFailedBoot "book.panic_on_fail" # If boot fails panic
      ++ optional cfg.panicOnOOM "vm.panic_on_oom" # panic immediately if oom killer is activated
      ++ optional cfg.panicOnHungTask "kernel.hung_task_panic=1" # Panic if hung task is found
      ++ optional (cfg.panicOnHungTaskTimeout ? true ) "hung_task_timeout_secs=${toString cfg.panicOnHungTaskTimeout}"; # Panic if hung task is found
}
