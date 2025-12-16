{...}: {
  imports = [
    ../../profiles/intel.nix
    ( import ../../profiles/disk-workstation-ext4.nix { device = "/dev/sda"; })
  ];

  config = {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "nat";
    networking.hostId = "3f8151fb";
    networking.domain = "home.lucasr.com";
  };
}
