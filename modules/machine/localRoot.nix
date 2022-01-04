{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  efiDir = "/boot/EFI";
  encryptedPartLabel = "primary";
  efiFsLabel = "efi";
  rootFsLabel = "nixos";
  luksDeviceName = "os-decrypted"; # This can be anything as it is made and used on the fly
in {

  imports = [ ./encryptedRoot.nix ];

  options.machine.localRoot = {
    enable = mkEnableOption "Enable the default desktop configuration";
    enableHibernation = mkEnableOption "Enable hibernation. Will create swap file the size of ram";
  };

  config = mkIf cfg.enable {

    fileSystems."/boot/EFI" = {
      device = "/dev/disk/by-label/efi";
      fsType = "vfat";
    };

    fileSystems."/" = {
      options = [ "noatime" "nodiratime" "discard" ];
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    # Define the hostname
    networking.hostName = cfg.hostname;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = cfg.stateVersion; # Did you read the comment?
  };
}

