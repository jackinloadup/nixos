{pkgs, ...}: {
  imports = [];

  config = {
    # Possible fix for bluetooth not connecting
    boot.kernelParams = ["btusb.enable_autosuspend=n"];

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    boot.kernelModules = ["kvm-amd"];
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod"];
    boot.initrd.kernelModules = ["kvm-amd"];
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.supportedFilesystems = ["btrfs"];
    boot.supportedFilesystems = ["btrfs"];
    # We have a lot of ram. We can wait a bit before we think we need to swap.
    # does this even matter if I don't have swap attached?
    boot.kernel.sysctl."vm.swappiness" = 5;

    # More tmp space is needed to build kernel
    # original 16G (50%), known needed 20G, new 24G
    boot.tmp.tmpfsSize = "75%";

    programs.fuse.userAllowOther = true;
    services.btrfs.autoScrub.enable = true;
    services.btrfs.autoScrub.fileSystems = ["/dev/disk/by-label/nixos"];

    hardware.opengl.extraPackages = with pkgs; [
      radeontop #  Top for amd cards. Could maybe be placed somewhere else? debug only if possible?
      radeon-profile
    ];

    fileSystems = let
      btrfs = subvol: {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=${subvol}"
          "compress=zstd"
          "autodefrag"
          "noatime"
          "x-gvfs-hide"
        ];
        neededForBoot = true;
      };
    in {
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "defaults"
          "size=2G"
          "mode=755"
          "noatime"
          "x-gvfs-hide"
        ];
      };

      "/boot" = {
        device = "/dev/disk/by-label/efi";
        fsType = "vfat";
        options = [
          "defaults"
          "x-gvfs-hide"
          "noatime"
        ];
      };

      # look into added  a reserve space?
      "/nix" = btrfs "nix";
      # mnt per user instead. which i think makes quite a bit of sense for future
      # potential on account limits ect
      # say limit user so they can't fill the computer completely
      "/persist/home" = btrfs "home";
      "/persist/etc" = btrfs "etc";
      "/persist/root" = btrfs "root";
      "/persist/lib" = btrfs "persist";
      "/var/log" = btrfs "log";

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
