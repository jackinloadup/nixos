{flake, pkgs, config, lib, ...}: let
inherit (lib) mkForce;
in {
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
    boot.kernelPackages = mkForce pkgs.linuxPackages_6_17;
    boot.kernelParams = [
      # Try disabling ASPM (this fixes 90% of MT7925 suspend issues
      # try to remove after kernel > 6.12
      #"pcie_aspm=off"
      # Deep sleep is more stable on AMD + Mediatek systems.
      # so says ai
      "mem_sleep_default=deep"
    ];


    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostId = "9b93167d";
    networking.hostName = "obsidian";
    networking.domain = "obsidian.systems";

    networking.dhcpcd.persistent = true;
  };
}
