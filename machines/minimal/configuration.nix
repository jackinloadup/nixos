{ self, inputs, pkgs, lib, ... }:

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
#      "lriutzel"
    ];
    adb = false;
    tui = false;
    sizeTarget = 0;
    autologin-tty1 = false;
    bluetooth = false;
    encryptedRoot = false;
    lowLevelXF86keys.enable = false;
    quietBoot = false;
    sdr = false;
    sound = false;
  };

  networking.hostName = "minimal";
  nix.maxJobs = lib.mkDefault 2;

  networking.networkmanager.enable = mkForce false;
  #security.wrappers.fusermount = mkForce null;
  #security.wrappers = builtins.removeAttrs config.security.wrappers [ "fusermount" ];

  security.wrappers =
    let
      mkSetuidRoot = source:  {
        setuid = true;
        owner = "root";
        group = "root";
        inherit source;
      };
    in mkForce {
      mount  = mkSetuidRoot "${lib.getBin pkgs.util-linux}/bin/mount";
      umount = mkSetuidRoot "${lib.getBin pkgs.util-linux}/bin/umount";
    };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

