{ ... }:

{
  imports = [
    ../../profiles/intel.nix
    ../../profiles/disk-workstation.nix
  ];

  config = {
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.loader.efi.canTouchEfiVariables = true;
    boot.extraModprobeConfig = "options snd-hda-intel enable_msi=1";
  };
}
