{pkgs, flake, config, ...}: {
  imports = [
    ../../profiles/disk-workstation-2.nix
    ../../profiles/amd.nix
    #flake.inputs.chaotic.nixosModules.default
  ];

  config = rec {
    boot.kernelParams = [
      "video=DP-8:3840x2160@60" # 4k 60hz
      "video=DP-2:3440x1440@60" # LG 34UM95 144p ultrawide 60hz
    ];

    #boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    boot.zfs.package = pkgs.zfs_unstable;
    #boot.kernelPackages = pkgs.zfs_unstable.latestCompatibleLinuxPackages;
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_8;
    #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod"];
    boot.loader.efi.canTouchEfiVariables = true;

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

    networking.hostId = "c99cd5f7";

    #fileSystems = {
    #  "/mnt/storage" = {
    #    device = "/dev/disk/by-label/storage";
    #    fsType = "ext4";
    #    neededForBoot = false;
    #    options = [
    #      "defaults"
    #      "relatime"
    #      "x-systemd.idle-timeout=60"
    #      "x-systemd.device-timeout=2s"
    #      "x-systemd.mount-timeout=2s"
    #      # "compress-force=zstd:14"
    #    ];
    #  };
    #};

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
