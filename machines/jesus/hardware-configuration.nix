{pkgs, ...}: {
  imports = [
    ../../profiles/intel.nix
    ../../profiles/disk-laptop-1.nix
    ../../profiles/mobile-device.nix
  ];

  config = {
    boot.initrd.availableKernelModules = ["ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod"];
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "jesus";
    networking.domain = "home.lucasr.com";
    networking.hostId = "e4075f97";


  };
}
