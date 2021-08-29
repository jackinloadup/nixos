{ config, lib, pkgs, ... }:

{
  imports = [
    ../full-encrypt.nix
    ../configuration.nix
    ../profiles/amd.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "uas"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
    };


    # Required for throttled when running on the 5.9 kernel.
    kernelParams = [
      "msr.allow_writes=on"
    ];

  };

  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-label/efi";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };



  hardware = {
    # Enable firmware for bluetooth/wireless (Intel® Wireless-AC 9560).
    enableRedistributableFirmware = true;

    # Enable bluetooth support.
    bluetooth = {
      enable = true;
      # High quality BT calls
      hsphfpd.enable = true;
    };

    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  ## Detect and managing bluetooth connections.
  #services.blueman = {
  #  enable = true;
  #};

  ## Enable periodic trim for long term SSD performance.
  #services.fstrim.enable = true;

  ## Enable updating firmware via the command line.
  #services.fwupd.enable = true;

  ## Enable cpu specific power saving features.
  #services.thermald.enable = true;

  ## Enable fix for lenovo cpu throttling issue.
  #services.throttled.enable = true;

  ## Enable general power saving features.
  #services.tlp = {
  #  enable = true;
  #};

  #services.xserver = {
  #  # Enable touchpad support.
  #  libinput = {
  #    enable = true;
  #    accelSpeed = "0.5";
  #  };

  #  # Enable the proprietary NVIDIA drivers.
  #  videoDrivers = [ "nvidia" ];
  #};

  networking = {
    hostName = "nixpad";

    # Enable wifi powersaving.
    networkmanager = {
      wifi = {
        powersave = true;
      };
    };
  };

  #nix.maxJobs = lib.mkDefault 8;
}
