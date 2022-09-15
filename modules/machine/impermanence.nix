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
          "/etc/NetworkManager/system-connections"
        ];
      };
      "/persist/lib" = {
        hideMounts = true;
        directories = [
          #"/var/log"
          "/var/lib/bluetooth"
          "/var/lib/systemd/coredump"
          "/var/lib/docker"
          "/var/lib/libvirt"
          "/var/lib/ipfs"
          "/var/lib/fwup"
          "/var/lib/iwd"
          #"/var/lib/syncthing"
          #"/var/lib/postgresql"
          { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
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

