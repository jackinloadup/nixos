{ self, inputs, pkgs, lib, ... }:
# machine runs kodi
with lib;
with inputs;
let
  inherit (lib) mkDefault;
  settings = import ../../settings;
  kodiSplash = "${pkgs.kodi}/share/kodi/media/splash.jpg";
in {

  imports = [
    ./hardware-configuration.nix
    ./auto-pair-ps3-remote.nix
  ];

  security.sudo.wheelNeedsPassword = false;
  services.fwupd.enable = mkForce false;
  services.getty = {
    autologinUser = "kodi";
    extraArgs = [
      "--noissue"
      "--noclear"
      "--nohints"
      "--nohostname"
      "--skip-login"
    ];
  };

  machine = {
    users = [
      "lriutzel"
      "kodi"
    ];
    bluetooth = true;
    sizeTarget = 1;
    quietBoot = true;
    minimal = true;
    tui = false;
    sound = true;
    virtualization = false;
    #displayManager = "gdm";
    windowManagers = [ ];
    kernel = {
      rebootAfterPanic = mkForce 10;
      panicOnOOM = mkForce true;
      #panicOnFailedBoot = mkForce true;
      panicOnHungTask = mkForce true;
      panicOnHungTaskTimeout = mkForce 1;
    };
  };

  gumdrop = {
    storageServer.enable = true;
    storageServer.media = true;
    storageServer.roms = true;
  };

  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
  ];
  nix.settings.max-jobs = mkDefault 2;

  nixpkgs = {
    overlays = [
      inputs.nur.overlay
      inputs.self.overlays.default
      inputs.self.overlays.kodi-wayland
      inputs.self.overlays.plymouth-no-gtk
      inputs.self.overlays.pipewire-minimal
    ];

    config.retroarch = {
      enableBsnes = true;
      enableDolphin = true;
      enableMGBA = true;
      enableMAME = true;
    };
  };

  boot.kernelPatches = [
    { name = "sony-bd-remote-buttons";
      patch = ../../patches/linux-sony-bd-remote.patch;
    }
  ];
  boot.plymouth = {
    enable = true;
  };


  virtualisation = rec {
    vmVariant = {
      networking.hostName = mkForce "natvm";
      #services.xserver.displayManager.defaultSession = mkForce "none+i3"a;
      boot.loader.efi.efiSysMountPoint = mkForce "/boot";
      boot.initrd.kernelModules = [ ];

      virtualisation = {
        #useEFIBoot = true;
        #useBootLoader = true;

        # https://github.com/NixOS/nixpkgs/issues/59219
        cores = 4;
        graphics = true;
        memorySize = 2048;
        qemu.networkingOptions = [ "-nic bridge,br=br0,model=virtio-net-pci,mac=30:9c:23:01:2f:82,helper=/run/wrappers/bin/qemu-bridge-helper" ];
        qemu.options = [
          #"-device virtio-gpu-pci"
          #"-device virtio-gpu-gl-pci"
          "-device virtio-vga-gl"
          "-display gtk,gl=on"
          "-vga none"
        ];
      };

      networking.interfaces = mkForce {
        eth0.useDHCP = true;
      };
    };

    vmVariantWithBootLoader = vmVariant;
  };

  hardware = {
    bluetooth.settings.General.Name = "Entertainment";
    opengl.enable = mkForce true;
    opengl.driSupport = mkForce true;
  };

  networking = {
    hostName = "nat";
    networkmanager.enable = mkForce false;

    dhcpcd = {
      wait = mkForce "ipv4"; # don't wait. That would take longer
      persistent = true;
    };

    interfaces.enp1s0.useDHCP = true;
    firewall = {
      # for the Kodi web interface
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };
  };

  # clean logs older than 2d
  services.cron.systemCronJobs = [
      "0 20 * * * root journalctl --vacuum-time=2d"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
