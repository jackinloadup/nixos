{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  imports = [ ];

  options.machine.virtualization = mkEnableOption "Enable virtualization";

  config = mkIf config.machine.virtualization {
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };

    security.polkit.enable = lib.mkForce true;

    # might only apply to libvirt
    environment.systemPackages = with pkgs; [ # if system is not minimal
      virt-top
      usbutils # for lsusb
    ] ++ (if cfg.sizeTarget > 0 then [ # if system is full user
      virt-manager # includes virt-install which maybe we want in cli?
    ] else []);

    users.users.lriutzel.extraGroups = [ "libvirtd" ];
  };
}
