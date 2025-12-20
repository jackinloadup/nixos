{ flake, ... }: {
  imports = [
    flake.inputs.nixos-hardware.nixosModules.common-pc-ssd
    flake.inputs.nixos-hardware.nixosModules.common-pc
    flake.inputs.nixos-hardware.nixosModules.common-cpu-intel
    ../../profiles/intel.nix
    (import ../../profiles/disk-workstation-ext4.nix { device = "/dev/sda"; })
  ];

  config = {
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "nat";
    networking.hostId = "3f8151fb";
    networking.domain = "home.lucasr.com";
  };
}
