{
  lib,
  flake,
  pkgs,
  config,
  device ? "/dev/sda",
  isEncrypted ? false,
  ramSize ? "16GiB",
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (builtins) hasAttr;
  inherit (pkgs) writeScriptBin;


  zfsPoolName = "zroot";
  rootPartionName = "nixos";
  impermanence = (hasAttr "machine" config) && config.machine.impermanence;
  tmpfsRoot = false;
in {
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
                name = "ESP";
                size = "2G";
                #bootable = true;
                # https://github.com/nix-community/disko/blob/master/docs/upgrade-guide.md#2023-04-07-d6f062e
                type = "EF00";
                #part-type = "primary";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  #mountOptions = [
                  #  "defaults"
                  #];
                };
              };
              swap = {
                size = ramSize;
                type = "8200";
                content = {
                  type = "swap";
                  randomEncryption = true;
                  resumeDevice = true; # resume from hiberation from this device
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
          postCreateHook = mkIf isEncrypted ''
            zfs set keylocation="prompt" ${zfsPoolName};
          '';
          rootFsOptions = {
            #compression = "lz4";
            compression = "zstd";
            #"com.sun:auto-snapshot" = "false";

            acltype = "posixacl";

            encryption = mkIf isEncrypted "on";
            # insert via secrets
            keylocation = mkIf isEncrypted "file:///tmp/disk.key";
            keyformat = mkIf isEncrypted "passphrase";

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
            "local" = unmountable; # Data that is replaceable
            "safe" = unmountable; # Data that is valued. Provides a sync point
            "local/nix" = filesystem "/nix" // {options.mountpoint = "legacy";};
          } // (if impermanence then {
            "local/etc" = filesystem "/persist/etc";
            "local/log" = filesystem "/persist/log";
            "safe/home" = filesystem "/persist/home";
            "safe/lib" = filesystem "/persist/lib";
          } else {}) // (if tmpfsRoot then {
            # Nothing handled above
          } else { # zfs managed root
            "local/root" =
              filesystem "/"
              // {
                postCreateHook = ''
                  zfs snapshot ${zfsPoolName}/local/root@blank
                '';
                options.mountpoint = "legacy";
              };
          });
        };
      };
    };

    # unsure why this isn't possible right now
    #fileSystems."/persist/etc".neededForBoot = mkIf impermanence true;
    #fileSystems."/persist/lib".neededForBoot = mkIf impermanence true;
  };
}
