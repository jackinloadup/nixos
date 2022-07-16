{ self, inputs, pkgs, lib, ... }:
# machine runs kodi
with lib;
with inputs;
let
  settings = import ../../settings;
in {

  imports = [
    ./hardware-configuration.nix
    base16.hmModule
  ];

  security.sudo.wheelNeedsPassword = false;
  #services.xserver.displayManager.autoLogin.user = "kodi";
  #services.xserver.displayManager.defaultSession = mkDefault "kodi";
  services.xserver.desktopManager.kodi.enable = true;
  services.getty.autologinUser = "kodi";

  machine = {
    users = [
      "lriutzel"
      "kodi"
    ];
    bluetooth = true;
    sizeTarget = 1;
    quietBoot = true;
    tui = true;
    sound = true;
    virtualization = false;
    #displayManager = "gdm";
    windowManagers = [ "i3" ];
    kernel = {
      rebootAfterPanic = mkForce 10;
      panicOnOOM = mkForce true;
      #panicOnFailedBoot = mkForce true;
      panicOnHungTask = mkForce true;
      panicOnHungTaskTimeout = mkForce 5;
    };
  };

  gumdrop = {
    storageServer.enable = true;
    storageServer.requiredForBoot = true;
    storageServer.media = true;
    storageServer.roms = true;
  };

  nix.maxJobs = lib.mkDefault 2;
  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
  ];

  nixpkgs = {
    overlays = [
      inputs.nur.overlay
      inputs.self.overlays.default
    ];

    config.retroarch = {
      enableBsnes = true;
      enableDolphin = true;
      enableMGBA = true;
      enableMAME = true;
    };
  };

  boot.plymouth = {
    enable = true;
  };

  virtualisation.vmVariant = {
    networking.hostName = mkForce "natvm";
    services.xserver.displayManager.defaultSession = mkForce "none+i3";
    virtualisation = {

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

  hardware.bluetooth.settings.General.Alias = "Entertainment";
  networking = {
    hostName = "nat";
    networkmanager.enable = mkForce false;

    dhcpcd = {
      #wait = "ipv4"; # don't wait. That would take longer
      persistent = true;
    };

    interfaces.enp1s0.useDHCP = true;
    firewall = {
      # for the Kodi web interface
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
