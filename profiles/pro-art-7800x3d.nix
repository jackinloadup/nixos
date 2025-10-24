{lib, pkgs, config, ...}:
let
  inherit (lib) mkForce;
in {
  config = {
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod"];
    boot.loader.efi.canTouchEfiVariables = true;
    # machine isn't physically moving. Keep same dhcp issued address
    networking.networkmanager.wifi.macAddress = mkForce "permanent";

    # doesn't always support zfs :-( I'll have to move away from it for desktops
    # for now moving back to mainline
    #boot.kernelPackages = pkgs.linuxPackages_zen;

    ##boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    #boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;

    # Disabled everything related to MEDIATEK Corp. MT7922 802.11ax in the BIOS
    # for zen
    #
    ## maybe not needed after 6.12.8 - I don't think it worked. :-( disable below
    ## https://www.reddit.com/r/linux/comments/1hv24zb/mt7922_no_longer_causes_kernel_panic_on_resume/
    ## https://forum.manjaro.org/t/intermittent-connection-loss-lag-spikes/174171/16
    #boot.extraModprobeConfig = ''
    #  options mt7921e disable_aspm=1
    #'';

    ## Diable Motherboard wifi and bluetooth due to driver issues
    ## Switching to using usb bt device
    ## disable 0a:00.0 Network controller: MEDIATEK Corp. MT7922 802.11ax PCI Express Wireless Network Adapter
    #services.udev.extraRules = ''
    #  ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:0a:00.0", RUN+="/bin/sh -c 'echo 1 > /sys/bus/pci/devices/0000:0a:00.0/remove'"
    #'';
  };
}
