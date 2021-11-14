{ self, ... }: {
  imports = [ ];

  # Required for throttled when running on the 5.9 kernel.
  #boot.kernelParams = [ "msr.allow_writes=on" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  #boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
       efiSupport = false;
       device = "nodev";
     };
   };

  #fileSystems."/boot" = {
  #  device = "/dev/disk/by-label/boot";
  #  fsType = "vfat";
  #  options = [ "defaults" "x-gvfs-hide" ];
  #};

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = [ "defaults" "x-gvfs-hide" ];
  };
}
