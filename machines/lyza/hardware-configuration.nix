{lib, ...}: {
  imports = [
    ../../profiles/intel.nix
    ../../profiles/disk-workstation-2.nix
  ];

  config = {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    boot.loader.efi.canTouchEfiVariables = true;
    boot.extraModprobeConfig = "options snd-hda-intel enable_msi=1";

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
