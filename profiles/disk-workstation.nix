{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (builtins) hasAttr;
  ## TODOS
  ## figure out how to make this by name/label it's an issue of pre/post disk
  ## formatting nixos does't really care about disk
  ##
  ## disko-create should have an ability to override disks by name:
  ##   $ disko-create --disk=sd=/dev/sdb
  ##
  hostname = config.networking.hostName;
  device = "/dev/sda"; # TODO change per host
  zfsPoolName = "zroot_${hostname}";
  rootPartionName = "nixos_${hostname}";
  impermanence = (hasAttr "machine" config) && config.machine.impermanence;
  tmpfsRoot = false;
in {
  # inputs is made accessible by passing it as a specialArg to nixosSystem{}
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = {
    environment.systemPackages = [
      (pkgs.writeScriptBin "disko-create" (config.system.build.formatScript))
      (pkgs.writeScriptBin "disko-mount" (config.system.build.mountScript))
      (pkgs.writeScriptBin "disko" (config.system.build.mountScript))
    ];

    boot.initrd.supportedFilesystems = ["zfs"];
    boot.supportedFilesystems = ["zfs"];

    services.zfs.autoScrub.enable = true;
    boot.zfs.forceImportRoot = true;

    disko.devices = {
      nodev = {
        "/" = mkIf tmpfsRoot {
          fsType = "tmpfs";
          mountOptions = [
            "defaults"
            "size=2G"
            "mode=755"
            "noatime"
          ];
        };
      };
      disk = {
        boot = {
          # The device we are planning to boot from
          inherit device;
          type = "disk";
          content = {
            type = "table";
            format = "gpt";
            partitions = [
              {
                type = "partition";
                name = "ESP";
                start = "1MiB";
                end = "512MiB";
                bootable = true;
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                  ];
                };
              }
              {
                type = "partition";
                name = rootPartionName;
                start = "512MiB";
                end = "100%";
                content = {
                  type = "zfs";
                  pool = "${zfsPoolName}";
                };
              }
            ];
          };
        };
      };
      zpool = {
        "${zfsPoolName}" = {
          type = "zpool";
          mode = "";
          options = {
            ashift = "12";
            autotrim = "on";
          };
          postCreateHook = ''
            zfs set keylocation="prompt" $name;
          '';
          rootFsOptions = {
            #compression = "lz4";
            compression = "zstd";
            #"com.sun:auto-snapshot" = "false";

            encryption = "on";
            acltype = "posixacl";
            # insert via secrets
            keylocation = "file:///tmp/disk.key";
            keyformat = "passphrase";

            mountpoint = "none";
            canmount = "off";
            xattr = "sa";
            dnodesize = "auto";
            normalization = "formD";
            relatime = "on";
          };
          #mountpoint = "/persist";

          datasets = let
            unmountable = {
              zfs_type = "filesystem";
              mountpoint = null;
              options.canmount = "off";
            };
            filesystem = mountpoint: {
              zfs_type = "filesystem";
              inherit mountpoint;
              #  options."com.sun:auto-snapshot" = "true";
            };
          in {
            "local" = unmountable;
            "safe" = unmountable;
            "local/nix" = filesystem "/nix" // {options.mountpoint = "legacy";};
            #} // mkIf impermanence {
            "local/etc" = filesystem "/persist/etc";
            "local/lib" = filesystem "/persist/lib";
            "local/log" = filesystem "/persist/log";
            "safe/home" = filesystem "/persist/home";
            #} // mkIf (!tmpfsRoot) {
            "local/root" =
              filesystem "/"
              // {
                postCreateHook = "zfs snapshot ${zfsPoolName}/local/root@blank";
                options.mountpoint = "legacy";
              };

            #zfs_fs = {
            #  zfs_type = "filesystem";
            #  mountpoint = "/zfs_fs";
            #  options."com.sun:auto-snapshot" = "true";
            #};
            #zfs_unmounted_fs = {
            #  zfs_type = "filesystem";
            #  options.mountpoint = "none";
            #};
            #zfs_legacy_fs = {
            #  zfs_type = "filesystem";
            #  options.mountpoint = "legacy";
            #  mountpoint = "/zfs_legacy_fs";
            #};
            #zfs_testvolume = {
            #  zfs_type = "volume";
            #  size = "10M";
            #  content = {
            #    type = "filesystem";
            #    format = "ext4";
            #    mountpoint = "/ext4onzfs";
            #  };
            #};
          };
        };
      };
    };
  };
}
