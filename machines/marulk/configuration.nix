{ self, inputs, pkgs, lib, ... }:
# Machine runs DNS and home-assistant vm
with lib;
with inputs;
let
  settings = import ../../settings;
in {

  imports = [
    ./hardware-configuration.nix
  ];

  machine = {
    users = [
      "lriutzel"
    ];
    sizeTarget = 1;
    quietBoot = true;
    home-assistant = true;
    tui = true;
    virtualization = true;
    windowManagers = [];
  };

  gumdrop = {
    adguard = true;
  };
  virtualisation.libvirtd.onShutdown = "shutdown";

  machine.kernel = {
    rebootAfterPanic = mkForce 10;
    panicOnOOM = mkForce true;
    panicOnHungTaskTimeout = mkForce 1;
  };

  nix.maxJobs = lib.mkDefault 2;
  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.default
  ];

  networking.hostName = "marulk";
  networking.networkmanager.enable = mkForce false;
  networking.bridges.br0.interfaces = ["enp1s0"];
  networking.interfaces.br0 = {
    useDHCP = true;
    ipv4.addresses = [
      # Capture IP for Adguard
      { address = "10.16.1.2"; prefixLength = 8; }
    ];
  };


  networking.dhcpcd = {
    #wait = "ipv4";
    persistent = true;
 };

  #networking.nat = {
  #  enable = true;
  #  externalInterface = "enp1s0";
  #  internalInterfaces = ["virbr0"];
  #  internalIPs = [
  #    "192.168.122.0/24"
  #  ];
  #  forwardPorts = [
  #    {
  #      destination = "192.168.122.182:1883";
  #      proto = "tcp";
  #      sourcePort = 1883;
  #    }
  #    {
  #      destination = "192.168.122.182:8123";
  #      proto = "tcp";
  #      sourcePort = 8123;
  #    }
  #  ];
  #};
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
