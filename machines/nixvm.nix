{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../full-encrypt.nix
    ../configuration.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "ahci"
        "sd_mod"
        "sr_mod"
      ];
    };

    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/EFI";
      };
    };
  };

  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-label/efi";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # nix.maxJobs = lib.mkDefault 2;


  networking.hostName = "nixvm";
}
