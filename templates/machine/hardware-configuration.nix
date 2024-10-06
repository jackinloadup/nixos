{
  flake,
  ...
}: {
  imports = [
    ../../profiles/intel.nix
    ../../profiles/amd.nix
  ];

  config = {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    boot.loader.efi.efiSysMountPoint = "/boot/EFI";
    boot.loader.efi.canTouchEfiVariables = true;

    fileSystems."/boot/EFI" = {
      device = "/dev/disk/by-label/boot";
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
        size = 2048;
      } # this big for hibernation 2Gb~
    ];

    nix.settings.max-jobs = mkDefault 2;

    nixpkgs.hostPlatform = "x86_64-linux";
    nixpkgs.overlays = [
      flake.inputs.self.overlays.default
    ];
  };
}
