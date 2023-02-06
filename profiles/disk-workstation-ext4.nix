{inputs, pkgs, config, ...}: {

  # inputs is made accessible by passing it as a specialArg to nixosSystem{}
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = {
    disko.devices = {
      nodev = {
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
      disk = {
        sd = {
          type = "disk";
          device = "/dev/vda";
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
                name = "nixos";
                start = "512MiB";
                end = "100%";
                part-type = "primary";
                bootable = true;
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
