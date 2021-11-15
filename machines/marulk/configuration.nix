{ self, inputs, pkgs, lib, ... }:

with inputs;
let
  settings = import ../../settings;
in {

  imports = [
    ./hardware-configuration.nix
    #base16.hmModule
  ];

  machine = {
    users = [
      "lriutzel"
    ];
    sizeTarget = 1;
    quietBoot = true;
    home-assistant = true;
    tui = true;
  };

  systemd.services.mosquitto.after = [ "network-online.target" ];

  starbase = {
  };

  #security.wrappers = {};
  #security.wrappers.fusemount = { source = "${pkgs.bash}/bin/bash";};
  #security.wrappers.fusemount3 = { source = "${pkgs.bash}/bin/bash";};

  networking.hostName = "marulk";
  nix.maxJobs = lib.mkDefault 2;

  networking.dhcpcd.wait = "ipv4";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  #networking.firewall.allowedUDPPorts = [ 5353 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
