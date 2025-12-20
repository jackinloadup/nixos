{ lib
, flake
, pkgs
, config
, device ? "/dev/sda"
, isEncrypted ? false
, ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (builtins) hasAttr;
  inherit (pkgs) writeScriptBin;

  ramSize = "16GiB";

  hostname = config.networking.hostName;
  zfsPoolName = "zroot_${hostname}";
  ## TODOS
  ## figure out how to make this by name/label it's an issue of pre/post disk
  ## formatting nixos does't really care about disk
  ##
  ## disko-create should have an ability to override disks by name:
  ##   $ disko-create --disk=sd=/dev/sdb
  ##
  rootPartionName = "nixos_${hostname}";
  impermanence = (hasAttr "machine" config) && config.machine.impermanence;
  tmpfsRoot = false;
  #isTesting = (hasAttr "backdoor" config.systemd.services);
  isTesting = true;
in
{
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
                #start = "0";
                #end = "1M";
                type = "EF02"; # for grub MBR
                #flags = [ "bios_grub" ];
              };
              esp = {
                #name = "ESP";
                size = "512M";
                #start = "1M";
                #end = "512M";
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
                # larger than 3G is not working when testing via
                # i suspect it is only an artifact of testing and some vm disk
                # size. I don't think it will effect setting this larger on
                # a real install
                # nix build '.#nixosConfigurations.chichi.config.system.build.installTest'

                size = "3G";
                #start = "-16G";
                #end = "100%";
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
                #start = "512M";
                #end = "-16G"; # leave 16GB for swap = to ram for hybernation
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
          # commented out due to
          # error: builder for '/nix/store/7ax5hb59bcd82lbz63byv8n7bpgv160l-disko-format.drv' failed with exit code 1;
          # last 10 log lines:
          # >     ^--^ SC2030 (info): Modification of name is local (to subshell caused by (..) group).
          # >
          # >
          # > In /nix/store/78gplx80z9vcicmrxvphb534higv5pk2-disko-format line 224:
          # >   zfs set keylocation="prompt" $name;
          # >                                ^---^ SC2031 (info): name was modified in a subshell. That change might be lost.
          # >
          # > For more information:
          # >   https://www.shellcheck.net/wiki/SC2030 -- Modification of name is local (to...
          # >   https://www.shellcheck.net/wiki/SC2031 -- name was modified in a subshell. ...
          #postCreateHook = ''
          #  zfs set keylocation="prompt" $name;
          #'';
          rootFsOptions = {
            #compression = "lz4";
            compression = "zstd";
            #"com.sun:auto-snapshot" = "false";

            acltype = "posixacl";

            mountpoint = "none";
            canmount = "off";
            xattr = "sa";
            dnodesize = "auto";
            normalization = "formD";
            relatime = "on";
          } // (if !isTesting then {
            encryption = "on";
            # insert via secrets
            keylocation = "file:///tmp/disk.key";
            keyformat = "passphrase";
          } else { });
          #mountpoint = "/persist";

          datasets =
            let
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
            in
            {
              "local" = unmountable; # Data that is replaceable
              "safe" = unmountable; # Data that is valued. Provides a sync point
              "local/nix" = filesystem "/nix" // { options.mountpoint = "legacy"; };
            } // (if config.machine.impermanence then {
              "local/etc" = filesystem "/persist/etc";
              "local/log" = filesystem "/persist/log";
              "safe/home" = filesystem "/persist/home";
              "safe/lib" = filesystem "/persist/lib";
            } else { }) // (if tmpfsRoot then {
              # Nothing handled above
            } else {
              # zfs managed root
              "local/root" = filesystem "/";
            });
          #{
          ##  postCreateHook = "zfs snapshot ${zfsPoolName}/local/root@blank";
          ##  options.mountpoint = "legacy";
          #};
        };
      };
    };

    fileSystems."/persist/etc".neededForBoot = true;
    fileSystems."/persist/lib".neededForBoot = true;
  };
}
