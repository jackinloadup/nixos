# to /etc/nixos/configuration.nix instead.
{ self, nixos-hardware, ... }: {
  imports = [
    ../../profiles/intel.nix
  ];

  # Required for throttled when running on the 5.9 kernel.
  #boot.kernelParams = [ "msr.allow_writes=on" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-label/efi";
    fsType = "vfat";
    options = [ "defaults" "x-gvfs-hide" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = [ "defaults" "x-gvfs-hide" ];
  };

  boot.resumeDevice = "/dev/disk/by-label/nixos";
}