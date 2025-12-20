{ lib, pkgs, ... }:
let
  inherit (lib) mkForce mkDefault;
in
{
  imports = [
    ./amd.nix
  ];

  config = {
    #boot.initrd.availableKernelModules = [ "usbhid" "ehci_pci" "nvme" "xhci_pci" "ahci" ];
    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
    boot.loader.efi.canTouchEfiVariables = true;

    #boot.kernelModules = [ "kvm-amd" "amd_gpio" ];
    boot.kernelModules = [ "kvm-amd" ];

    # Play with TPM. Hope to have ssh host key come from tpm.
    # Hangs on boot causes 1:30 delay
    security.tpm2.enable = false;
    boot.initrd.systemd.tpm2.enable = false;

    # machine isn't physically moving. Keep same dhcp issued address
    networking.networkmanager.wifi.macAddress = mkForce "permanent";

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
