{ self, ... }: {
  imports = [ ];

  # Required for throttled when running on the 5.9 kernel.
  #boot.kernelParams = [ "msr.allow_writes=on" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";
  boot.loader.efi.canTouchEfiVariables = true;

  # We have a lot of ram. We can wait a bit before we think we need to swap.
  # does this even matter if I don't have swap attached?
  boot.kernel.sysctl."vm.swappiness" = 5;


  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-label/efi";
    fsType = "vfat";
    options = [
      "defaults"
      "x-gvfs-hide"
      "noatime"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = [
      "defaults"
      "x-gvfs-hide"
      "noatime"
      "discard"
    ];
  };

  fileSystems."/mnt" = {
    device = "/dev/disk/by-label/storage";
    fsType = "ext4";
    neededForBoot = false;
    options = [
      "defaults"
      "relatime"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=2s"
      "x-systemd.mount-timeout=2s"
    ];
  };

  #swapDevices = [
  #  { device = "/var/swapfile"; size = 34000; } # this big for hibernation 34Gb~
  #];

  #boot = {
  #  # filefrag -v /var/swapfile to get offset
  #  kernelParams = ["resume=/var/swapfile" "resume_offset=17887232" ]; 
  #  resumeDevice = "/dev/disk/by-label/nixos";
  #};
}
