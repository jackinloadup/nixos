{
  lib,
  flake,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (builtins) hasAttr;
  inherit (pkgs) writeScriptBin;
in {
  config = {
    boot.initrd.supportedFilesystems = ["zfs"];
    boot.supportedFilesystems = ["zfs"];

    services.zfs.autoScrub.enable = true;
    boot.zfs.forceImportRoot = true;
    #boot.zfs.package = pkgs.zfs_unstable;

    # depreciated pointed at the default kernel now
    #boot.kernelPackages = pkgs.zfs_unstable.latestCompatibleLinuxPackages;
    #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    # tried to set due to Zen kernel set in another place?
    #boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;

    # Added due to issue with kernel panics after suspend.
    # I suspect this is due to zfs.
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

  };
}
