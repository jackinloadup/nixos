{inputs, ...}: {

  # inputs is made accessible by passing it as a specialArg to nixosSystem{}
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = {
    disko.devices.nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=2G"
          "mode=755"
          "noatime"
        ];
      };
    };
    disko.devices.disk = {
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
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
                options = [
                  "defaults"
                ];
              };
            }
            {
              type = "partition";
              name = "zfs";
              start = "512MiB";
              end = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            }
          ];
        };
      };
      zpool = {
        zroot = {
          type = "zpool";
          mode = "mirror";
          rootFsOptions = {
            compression = "lz4";
            "com.sun:auto-snapshot" = "false";
          };
          mountpoint = "/persist";

          datasets = {
            nix = {
              zfs_type = "filesystem";
              mountpoint = "/nix";
            };
            persist-etc = {
              zfs_type = "filesystem";
              mountpoint = "/persist/etc";
            };
            persist-lib = {
              zfs_type = "filesystem";
              mountpoint = "/persist/lib";
            };
            persist-home = {
              zfs_type = "filesystem";
              mountpoint = "/persist/home";
            };
            persist-root = {
              zfs_type = "filesystem";
              mountpoint = "/persist/root";
            };
            persist-log = {
              zfs_type = "filesystem";
              mountpoint = "/var/log";
            };
            # home
            # etc
            # root
            # persist
            # log

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
