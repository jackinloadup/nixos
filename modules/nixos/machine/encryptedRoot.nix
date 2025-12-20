{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.machine;
in
{
  options.machine.encryptedRoot = mkEnableOption "Enable luks handling for /root is encyption";

  config = mkIf cfg.encryptedRoot {
    boot = {
      initrd = {
        luks.devices."os-decrypted" = {
          device = "/dev/disk/by-partlabel/primary";
          preLVM = true;
          allowDiscards = true; # maybe insecure?? could hint at structure?
          #  passwordFile = "/etc/secrets/initrd/keyfile0.bin";
        };
        #secrets = {
        #  # Create /mnt/etc/secrets/initrd directory and copy keys to it
        #  "/etc/secrets/initrd/keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
        #};
      };
    };
  };
}
