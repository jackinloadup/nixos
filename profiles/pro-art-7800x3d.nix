{lib, pkgs, ...}:
let
  inherit (lib) mkForce;
in {
  config = {
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod"];
    boot.loader.efi.canTouchEfiVariables = true;
    # machine isn't physically moving. Keep same dhcp issued address
    networking.networkmanager.wifi.macAddress = mkForce "permanent";
    #boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    boot.kernelPackages = pkgs.linuxPackages_zen;
    #boot.kernelPackages = pkgs.zfs_unstable.latestCompatibleLinuxPackages;
    #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };
}
