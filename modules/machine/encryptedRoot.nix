{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  config = mkIf cfg.encryptedRoot {
    boot = {
      initrd = {
        luks.devices."os-decrypted" = {
          device = "/dev/disk/by-partlabel/primary";
          preLVM = true;
          allowDiscards = true; # maybe insecure?? could hint at structure?
          #  keyFile = "/etc/secrets/initrd/keyfile0.bin";
        };
        #secrets = {
        #  # Create /mnt/etc/secrets/initrd directory and copy keys to it
        #  "/etc/secrets/initrd/keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
        #};
      };
    };
  };
}
