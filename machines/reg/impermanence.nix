{ self, inputs, pkgs, lib, ... }:

{
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
}
