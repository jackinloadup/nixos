{ self, lib, ... }:

with lib;
{
  imports = [
    ../../profiles/intel.nix
    ../../profiles/disk-workstation.nix
  ];

  # Required for throttled when running on the 5.9 kernel.
  #boot.kernelParams = [ "msr.allow_writes=on" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "kvm-intel" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = "options snd-hda-intel enable_msi=1";
}
