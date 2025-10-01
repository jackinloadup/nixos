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

  ## TODOS
  ## figure out how to make this by name/label it's an issue of pre/post disk
  ## formatting nixos does't really care about disk
  ##
  ## disko-create should have an ability to override disks by name:
  ##   $ disko-create --disk=sd=/dev/sdb
  ##
  hostname = config.networking.hostName;
  device = "/dev/nvme0n1"; # TODO change per host
  zfsPoolName = "zroot_${hostname}";
  rootPartionName = "nixos_${hostname}";
  impermanence = (hasAttr "machine" config) && config.machine.impermanence;
  tmpfsRoot = false;
in {
  # inputs is made accessible by passing it as a specialArg to nixosSystem{}
  imports = [
    flake.inputs.disko.nixosModules.disko
    ./zfs.nix
  ];

  config = {
    environment.systemPackages = with config.system.build; [
      (writeScriptBin "disko-create" formatScript)
      (writeScriptBin "disko-mount" mountScript)
      (writeScriptBin "disko" mountScript)
    ];

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
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
              esp = {
                size = "512M";
                #bootable = true;
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                  ];
                };
              };
              root = {
                name = rootPartionName;
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "${zfsPoolName}";
                };
              };
            };
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
            zfs set keylocation="prompt" ${zfsPoolName};
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
          mountOptions = [ "x-gvfs-hide" ]; # didn't seem to work

          datasets = let
            unmountable = {
              type = "zfs_fs";
              mountpoint = null;
              options.canmount = "off";
            };
            filesystem = mountpoint: {
              type = "zfs_fs";
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
          };
        };
      };
    };

    fileSystems."/persist/etc".neededForBoot = true;
    fileSystems."/persist/lib".neededForBoot = true;
  };
}
