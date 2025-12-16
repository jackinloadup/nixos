{pkgs, ...}: {
  imports = [
    ../../profiles/intel.nix
    ../../profiles/disk-laptop-1.nix
  ];

  config = {
    #boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    boot.initrd.availableKernelModules = ["ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod"];
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "jesus";
    networking.domain = "home.lucasr.com";
    networking.hostId = "e4075f97";


  };
}
