{...}: {
  imports = [
    ../../profiles/intel.nix
  ];

  config = {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/efi";
      fsType = "vfat";
      options = ["defaults" "x-gvfs-hide"];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = ["defaults" "x-gvfs-hide"];
    };

    swapDevices = [
      {
        device = "/var/swapfile";
        size = 1024;
      } # we could use more hard drive space
    ];
  };
}
