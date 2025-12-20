{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkForce mkEnableOption genAttrs optionals attrNames;
  cfg = config.machine;
  ifTui = cfg.sizeTarget > 0;
  ifGraphical = cfg.sizeTarget > 1;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: { extraGroups = groups; }));
in
{
  config = mkIf config.virtualisation.libvirtd.enable {
    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd = {
      onShutdown = "shutdown";
      parallelShutdown = 5;
      qemu = {
        swtpm.enable = true;
        verbatimConfig = ''
          remember_owner = 0
        '';
      };
    };
    # default is 300 (5 min)
    systemd.services.libvirt-guests.environment.SHUTDOWN_TIMEOUT = mkForce "30";

    # TODO added nested flag
    #boot.extraModprobeConfig = "options kvm_intel nested=1";

    security.polkit.enable = mkForce true; # needed for virt-manager?

    # might only apply to libvirt
    environment.systemPackages =
      [
        # if system is minimal
        pkgs.virt-top
        pkgs.usbutils # for lsusb
      ]
      ++ optionals ifTui [
        pkgs.qemu
      ]
      ++ optionals ifGraphical [
        pkgs.virt-manager # includes virt-install which maybe we want in cli?
        pkgs.spice-gtk
      ];

    users.users = addExtraGroups normalUsers [ "libvirtd" ];
  };
}
