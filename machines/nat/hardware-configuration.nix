{ self, lib, ... }:

{
  imports = [
    ../../profiles/intel.nix
  ];

  # Required for throttled when running on the 5.9 kernel.
  #boot.kernelParams = [ "msr.allow_writes=on" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "kvm-intel" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = "options snd-hda-intel enable_msi=1";

  fileSystems."/boot" = {
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
    { device = "/var/swapfile"; size = 1024; } # we could use more hard drive space
  ];
}
