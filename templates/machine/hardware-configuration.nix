{ flake
, ...
}: {
  imports = [
    ../../profiles/intel.nix
    ../../profiles/amd.nix
  ];

  config = {
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.loader.efi.efiSysMountPoint = "/boot/EFI";
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostId = "";
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
