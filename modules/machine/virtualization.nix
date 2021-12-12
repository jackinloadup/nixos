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

    # might only apply to libvirt
    environment.systemPackages = with pkgs; mkIf (cfg.sizeTarget > 0) [ # if system is not minimal
      virt-top
    ] // mkIf (cfg.sizeTarget > 1) [ # if system is full user
      virt-manager
    ];

    #users.users.lriutzel.extraGroups = [ "docker" ];
  };
}
