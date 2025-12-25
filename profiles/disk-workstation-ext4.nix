{ device ? "/dev/nvme0n1" }:
{ flake
, pkgs
, config
, ...
}:
# simple error checking to ensure garbage isn't passed in
#assert lib.asserts.assertOneOf "device" device [
#  "bar"
#  "baz"
#  "/dev/*"
#  # other valid choices ...
#];

{
  # inputs is made accessible by passing it as a specialArg to nixosSystem{}
  imports = [
    flake.inputs.disko.nixosModules.disko
  ];

  config = {
    # TODO should this be behind a flag limiting the script to the installer?
    environment.systemPackages = [
      (pkgs.writeScriptBin "disko-create" config.system.build.formatScript)
      (pkgs.writeScriptBin "disko-mount" config.system.build.mountScript)
      (pkgs.writeScriptBin "disko" config.system.build.mountScript)
    ];

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          inherit device;
          content = {
            type = "table";
            format = "gpt";
            partitions = [
              {
                name = "ESP";
                start = "1MiB";
                end = "512MiB";
                fs-type = "fat32";
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
                name = "nixos";
                start = "512MiB";
                end = "100%";
                part-type = "primary";
                #bootable = true;
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
