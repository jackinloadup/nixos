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

    # maybe not needed after 6.12.8
    # https://www.reddit.com/r/linux/comments/1hv24zb/mt7922_no_longer_causes_kernel_panic_on_resume/
    # https://forum.manjaro.org/t/intermittent-connection-loss-lag-spikes/174171/16
    boot.extraModprobeConfig = ''
      options mt7921e disable_aspm=1
    '';
  };
}
