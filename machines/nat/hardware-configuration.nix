{ self, ... }: {
  imports = [
    ../../profiles/intel.nix
  ];

  # Required for throttled when running on the 5.9 kernel.
  #boot.kernelParams = [ "msr.allow_writes=on" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "kvm-intel" ];
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-label/efi";
    fsType = "vfat";
    options = [ "defaults" "x-gvfs-hide" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = [ "defaults" "x-gvfs-hide" ];
  };

  swapDevices = [
    { device = "/var/swapfile"; size = 2048; } # this big for hibernation 2Gb~
  ];
}
