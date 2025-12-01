{
  self,
  flake,
  pkgs,
  lib,
  ...
}:
# Machine is a work computer for obsidian.systems
let
  inherit (lib) mkForce mkDefault;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    boot.initrd.verbose = true;

    boot.initrd = {
      systemd.emergencyAccess = true;
    };

    boot.kernelParams = [
      "rd.shell"              # Drop to shell if initrd fails
      #"rd.break"              # Break before switching root
      "systemd.log_level=debug"
      "debug"
      "boot.shell_on_fail"    # Shell on failure
    ];

    networking.hostName = "obsidian";

    networking.dhcpcd.persistent = true;


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?

  };
}
