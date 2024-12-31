{flake, pkgs, config, lib, ...}: {
  imports = [
    ../../profiles/amd.nix
    (import ../../profiles/disk-workstation-3.nix {
      inherit flake pkgs config lib;
      device = "/dev/nvme0n1";
      isEncrypted = false;
    })
  ];

  config = {
    boot.initrd.availableKernelModules = [ "usbhid" "ehci_pci" "nvme" "xhci_pci" "ahci" ];
    boot.loader.efi.canTouchEfiVariables = true;
    #boot.extraModprobeConfig = "options snd-hda-intel enable_msi=1";
    boot.kernelModules = [ "kvm-amd" "amd_gpio" ];

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
