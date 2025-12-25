{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkDefault;

  # Taken from https://wiki.nixos.org/wiki/ZFS
  # Warning: This will often result in the Kernel version going backwards as
  # Kernel versions become end-of-life and are removed from Nixpkgs. If you
  # need more control over the Kernel version due to hardware requirements,
  # consider simply pinning a specific version rather than calculating it as
  # below.
  zfsCompatibleKernelPackages = lib.filterAttrs
    (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name) != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  config = {
    boot.initrd.supportedFilesystems = [ "zfs" ];
    boot.supportedFilesystems = [ "zfs" ];

    services.zfs.autoScrub.enable = true;
    boot.zfs.forceImportRoot = true;
    #boot.zfs.package = pkgs.zfs_unstable;

    boot.kernelPackages = mkDefault latestKernelPackage;

    # tried to set due to Zen kernel set in another place?
    #boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;

    # Added due to issue with kernel panics after suspend.
    # try allowing sleep via suspend due to obsidian laptop using zfs
    # https://discourse.nixos.org/t/zfs-and-hibernate-suspend-to-disk/64992/3
    systemd.targets.sleep.enable = true;
    systemd.targets.suspend.enable = true;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

  };
}
