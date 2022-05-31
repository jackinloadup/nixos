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
        verbatimConfig = ''
          remember_owner = 0
        '';
      };
    };

    # TODO added nested flag
    #boot.extraModprobeConfig = "options kvm_intel nested=1";

    security.polkit.enable = lib.mkForce true; # needed for virt-manager?

    # might only apply to libvirt
    environment.systemPackages = with pkgs; [ # if system is minimal
      virt-top
      usbutils # for lsusb
    ] ++ (if cfg.sizeTarget > 0 then [ # if system is full user
      qemu
      virt-manager # includes virt-install which maybe we want in cli?
      spice-gtk
    ] else []);

    users.users.lriutzel.extraGroups = [ "libvirtd" ];
  };
}
