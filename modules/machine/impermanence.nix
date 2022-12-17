{ lib, pkgs, config, ... }:

# If extraOpts can be expressed in home-manager that
# would be more ideal or at least an alterate if using
# nix seporate from nixos

with lib;
{
  imports = [ ];

  options.machine.impermanence = mkEnableOption "Enable impermanence";

  config = mkIf config.machine.impermanence {
    environment.persistence = {
      "/persist/etc" = {
        hideMounts = true;
        directories = [
        ] ++ optionals config.networking.networkmanager.enable [
          "/etc/NetworkManager/system-connections"
        ];
      };
      "/persist/lib" = {
        hideMounts = true;
        directories = [
          #"/var/log"
          #"/var/lib/postgresql"
        #] ++ optionals config.systemd.package.withCoredump [ # requires wip
        # patch
          "/var/lib/systemd/coredump"
        ] ++ optionals config.hardware.bluetooth.enable [ # requires wip
          "/var/lib/bluetooth"
        ] ++ optionals config.virtualisation.docker.enable [
          "/var/lib/docker"
        ] ++ optionals config.virtualisation.libvirtd.enable [
          "/var/lib/libvirt"
        ] ++ optionals config.services.blueman.enable [
          "/var/lib/blueman"
        ] ++ optionals config.services.colord.enable [
          { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
        ] ++ optionals config.services.kubo.enable [ # ipfs
          "/var/lib/ipfs"
        ] ++ optionals config.services.fwupd.enable [
          "/var/lib/fwup"
        ] ++ optionals config.networking.wireless.iwd.enable [
          "/var/lib/iwd"
        ] ++ optionals config.services.syncthing.enable [
          "/var/lib/syncthing"
        ];
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          { file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
        ];
      };
    };
  };

}

