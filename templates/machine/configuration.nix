{
  self,
  flake,
  pkgs,
  lib,
  ...
}:
# Machine runs DNS and home-assistant vm
let
  inherit (lib) mkForce mkDefault;
  settings = import ../../settings;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    boot.initrd.verbose = false;

    machine = {
      users = [ "lriutzel" ];
      sizeTarget = 1;
      tui = true;
    };

    networking.hostName = "rename";

    networking.dhcpcd.persistent = true;


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?

  };
}
