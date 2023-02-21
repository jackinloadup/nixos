{ pkgs, ... }:

{
  imports = [
    ../../profiles/intel.nix
  ];

  config = {
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod" ];
    boot.loader.efi.canTouchEfiVariables = true;

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/efi";
      fsType = "vfat";
      options = [
        "defaults"
        "x-gvfs-hide"
        "noatime"
        "nodiratime"
      ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [
        "defaults"
        "x-gvfs-hide"
        "noatime"
        "nodiratime"
        "discard"
      ];
    };

    boot.resumeDevice = "/dev/disk/by-label/nixos";
  };
}
