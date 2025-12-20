{ pkgs, flake, config, ... }: {
  imports = [
    flake.inputs.nixos-hardware.nixosModules.common-pc-ssd
    flake.inputs.nixos-hardware.nixosModules.common-pc
    flake.inputs.nixos-hardware.nixosModules.common-cpu-amd
    flake.inputs.nixos-hardware.nixosModules.common-gpu-amd
    flake.inputs.nixos-facter-modules.nixosModules.facter
    ../../profiles/disk-workstation-2.nix
    ../../profiles/amd.nix
    ../../profiles/pro-art-7800x3d.nix
    #flake.inputs.chaotic.nixosModules.default
  ];

  config = rec {
    facter.reportPath = ./facter.json;

    boot.kernelParams = [
      "video=DP-8:3840x2160@60" # 4k 60hz
      "video=DP-2:3440x1440@60" # LG 34UM95 144p ultrawide 60hz
    ];


    #boot.initrd.supportedFilesystems = ["btrfs"];
    #boot.supportedFilesystems = ["btrfs"];
    # We have a lot of ram. We can wait a bit before we think we need to swap.
    # does this even matter if I don't have swap attached?
    boot.kernel.sysctl."vm.swappiness" = 5;

    # More tmp space is needed to build kernel
    # original 16G (50%), known needed 20G, new 24G
    boot.tmp.tmpfsSize = "75%";

    programs.fuse.userAllowOther = true;
    #services.btrfs.autoScrub.enable = true;
    #services.btrfs.autoScrub.fileSystems = ["/dev/disk/by-label/nixos"];

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "reg";
    networking.domain = "home.lucasr.com";
    networking.hostId = "3182e8f0";

    fileSystems = {
      "/mnt/storage" = {
        device = "/dev/disk/by-label/storage";
        fsType = "ext4";
        neededForBoot = false;
        options = [
          "defaults"
          "relatime"
          "x-systemd.idle-timeout=60"
          "x-systemd.device-timeout=2s"
          "x-systemd.mount-timeout=2s"
          # "compress-force=zstd:14"
        ];
      };
    };

    #swapDevices = [
    #  { device = "/var/swapfile"; size = 34000; } # this big for hibernation 34Gb~
    #];

    #boot = {
    #  # filefrag -v /var/swapfile to get offset
    #  kernelParams = ["resume=/var/swapfile" "resume_offset=17887232" ];
    #  resumeDevice = "/dev/disk/by-label/nixos";
    #};
  };
}
