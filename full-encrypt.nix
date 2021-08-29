{config, pkgs, ... }:

{
  imports = [ ];

  boot = {
    initrd = {
      luks.devices."os-decrypted" = {
        device = "/dev/disk/by-partlabel/primary";
        preLVM = true;
      #  keyFile = "/etc/secrets/initrd/keyfile0.bin";
        allowDiscards = true;
      };
      #secrets = {
      #  # Create /mnt/etc/secrets/initrd directory and copy keys to it
      #  "/etc/secrets/initrd/keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      #};
    };
  };
}
