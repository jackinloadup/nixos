{ lib
, inputs
, pkgs
, config
, ...
}:
let
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
  device = "/dev/sda"; # TODO change per host
  impermanence = (hasAttr "machine" config) && config.machine.impermanence;
  tmpfsRoot = false;
in
{
  # inputs is made accessible by passing it as a specialArg to nixosSystem{}
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = {
    environment.systemPackages = with config.system.build; [
      (writeScriptBin "disko-create" formatScript)
      (writeScriptBin "disko-mount" mountScript)
      (writeScriptBin "disko" mountScript)
    ];

    disko.devices = {
      #nodev = {
      #  "/" = mkIf tmpfsRoot {
      #    fsType = "tmpfs";
      #    mountOptions = [
      #      "defaults"
      #      "size=2G"
      #      "mode=755"
      #      "noatime"
      #    ];
      #  };
      #};
      disk = {
        boot = {
          # The device we are planning to boot from
          inherit device;
          # https://wiki.odroid.com/odroid-n2/software/partition_table
          type = "disk";
          content = {
            type = "table";
            format = "gpt";
            partitions = [
              {
                name = "mbr"; #  BL1 / MBR 
                start = "0B"; # from sector 0
                end = "512B"; # to sector 0
                type = "EF02"; # for grub MBR
              }
              {
                name = "bootloader"; # U-Boot
                start = "512B"; # from sector 1
                end = "983040B"; # to sector 1919
                #bootable = true;
                #content = {
                #  type = "filesystem";
                #  format = "vfat";
                #  mountpoint = "/boot";
                #  mountOptions = [
                #    "defaults"
                #  ];
                #};
              }
              {
                name = "env"; # U-Boot Environment
                start = "983552B"; # from sector 1920
                end = "1048576B"; # to sector 2047
                #bootable = true;
                #content = {
                #  type = "filesystem";
                #  format = "vfat";
                #  mountpoint = "/boot";
                #  mountOptions = [
                #    "defaults"
                #  ];
                #};
              }
              {
                name = "boot"; #  FAT32 for boot
                start = "1049088B";
                end = "135266304B";
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
                name = "nixos";
                start = "135266816B"; # from sector 264192
                end = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              }
            ];
          };
        };
      };
    };
  };
}
