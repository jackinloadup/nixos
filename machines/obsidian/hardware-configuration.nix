{flake, pkgs, config, lib, ...}: {
  imports = [
    #flake.inputs.nixos-facter-modules.nixosModules.facter
    (import ../../profiles/disk-laptop-2.nix {
      inherit flake pkgs config lib;
      device = "/dev/nvme0n1";
      isEncrypted = true;
      ramSize = "94G";
    })
    ../../profiles/amd.nix
    ../../profiles/mobile-device.nix
  ];

  config = {
    boot.initrd.availableKernelModules = [ "nvme" "ahci" "thunderbolt" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostId = "9b93167d";
    networking.hostName = "obsidian";

    networking.dhcpcd.persistent = true;
  };
}
