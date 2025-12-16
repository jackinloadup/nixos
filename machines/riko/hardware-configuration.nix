{pkgs, flake, ...}: {
  imports = [
    flake.inputs.nixos-facter-modules.nixosModules.facter
    ../../profiles/intel.nix
    ../../profiles/mobile-device.nix
  ];

  config = {
    facter.reportPath = ./facter.json;

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    boot.initrd.availableKernelModules = ["ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod"];
    boot.loader.efi.canTouchEfiVariables = true;

    boot.resumeDevice = "/dev/disk/by-label/nixos";

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "riko";
    networking.domain = "home.lucasr.com";
    networking.hostId = "e3320aa2";

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
  };
}
