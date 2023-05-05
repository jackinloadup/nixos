{
  lib,
  pkgs,
  config,
  ...
}:
# If extraOpts can be expressed in home-manager that
# would be more ideal or at least an alterate if using
# nix seporate from nixos
let
  inherit (lib) mkIf mkEnableOption optionals;
in {
  imports = [];

  options.machine.impermanence = mkEnableOption "Enable impermanence";

  config = mkIf config.machine.impermanence {
    programs.fuse.userAllowOther = true;

    environment.persistence = {
      "/persist/etc" = {
        hideMounts = true;
        directories =
          [
          ]
          ++ optionals config.networking.networkmanager.enable [
            "/etc/NetworkManager/system-connections"
          ];
        files = [
          "/etc/machine-id"
          {
            file = "/etc/nix/id_rsa";
            parentDirectory = {mode = "u=rwx,g=rx,o=rx";};
          }
        ];
      };
      "/persist/lib" = {
        hideMounts = true;
        directories =
          [
            # The /var/lib/nixos directory contains the uid and gid map for
            # entities without a static id. Not persisting them means your user
            # and group ids could change between reboots
            # https://github.com/nix-community/impermanence/pull/114
            "/var/lib/nixos"
            #"/var/log"
            #"/var/lib/postgresql"
            #] ++ optionals config.systemd.package.withCoredump [ # requires wip
            # patch
            "/var/lib/systemd/coredump"
          ]
          ++ optionals config.hardware.bluetooth.enable [
            # requires wip
            "/var/lib/bluetooth"
          ]
          ++ optionals config.virtualisation.docker.enable [
            "/var/lib/docker"
          ]
          ++ optionals config.virtualisation.libvirtd.enable [
            "/var/lib/libvirt"
          ]
          ++ optionals config.services.blueman.enable [
            "/var/lib/blueman"
          ]
          ++ optionals config.services.colord.enable [
            {
              directory = "/var/lib/colord";
              user = "colord";
              group = "colord";
              mode = "u=rwx,g=rx,o=";
            }
          ]
          ++ optionals config.services.kubo.enable [
            # ipfs
            "/var/lib/ipfs"
          ]
          ++ optionals config.services.fwupd.enable [
            "/var/lib/fwup"
          ]
          ++ optionals config.networking.wireless.iwd.enable [
            "/var/lib/iwd"
          ]
          ++ optionals config.services.postgresql.enable [
            "/var/lib/postgresql"
          ]
          ++ optionals config.services.pgadmin.enable [
            "/var/lib/private/pgadmin"
          ]
          ++ optionals config.services.hydra.enable [
            "/var/lib/hydra"
          ]
          ++ optionals config.services.syncthing.enable [
            "/var/lib/syncthing"
          ];
      };
    };
  };
}
