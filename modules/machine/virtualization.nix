{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  ifTui = if (cfg.sizeTarget > 0) then true else false;
  ifGraphical = if (cfg.sizeTarget > 1) then true else false;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  imports = [ ];

  options.machine.virtualization = mkEnableOption "Enable virtualization";

  config = mkIf config.machine.virtualization {
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

    virtualisation.spiceUSBRedirection.enable = true;
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
    ] ++ optionals ifTui [
      qemu
    ] ++ optionals ifGraphical [
      virt-manager # includes virt-install which maybe we want in cli?
      spice-gtk
    ];

    users.users = addExtraGroups normalUsers [ "libvirtd" ];
  };
}
