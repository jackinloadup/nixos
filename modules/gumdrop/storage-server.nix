{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop.storageServer = mkEnableOption "Setup connection to storage server";

  config = mkIf config.gumdrop.storageServer {
    systemd.services = {
      "freenas-lookup" = {
        enable = true;
        restartIfChanged = false;
        description = "wait until freenas dns returns";
        after = [ "nss-lookup.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart =  "/bin/sh -c 'while ! ${pkgs.host}/bin/host freenas.home.lucasr.com; do sleep 1; done'";
          Type = "oneshot";
        };
      };
    };
    # https://nixos.wiki/wiki/NFS
    fileSystems."/gumdrop" = {
      device = "freenas.home.lucasr.com:/mnt/storage";
      fsType = "nfs";
      options = [
        "noauto" # lazy mounting
        "noatime"
        "nodiratime"
        "x-systemd.automount" # lazy mounting
        "x-systemd.idle-timeout=600" # disconnects after 10 minutes (i.e. 600 seconds)
        "x-systemd.after=freenas-lookup.service" # Don't try to connect until network is online. duh
        #"nfsvers=4.2" # not sure if needed but we can specify the specific version
      ];
    };
  };
}
