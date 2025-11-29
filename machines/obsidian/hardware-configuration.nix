{flake, pkgs, config, lib, ...}: {
  imports = [
    #flake.inputs.nixos-facter-modules.nixosModules.facter
    (import ../../profiles/disk-laptop-2.nix {
      inherit flake pkgs config lib;
      device = "/dev/nvme0n1";
      isEncrypted = true;
    })
    ../../profiles/amd.nix
    ../../profiles/mobile-device.nix
  ];

  config = {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    boot.loader.efi.efiSysMountPoint = "/boot/EFI";
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostId = "9b93167d";
  };
}
