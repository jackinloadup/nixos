{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop.storageServer = mkEnableOption "Setup connection to storage server";

  config = mkIf config.gumdrop.storageServer {
    # https://nixos.wiki/wiki/NFS
    fileSystems."/gumdrop" = {
      device = "freenas.home.lucasr.com:/mnt/storage";
      fsType = "nfs";
      options = [
        "noauto" # lazy mounting
        "x-systemd.automount" # lazy mounting
        "x-systemd.idle-timeout=600" # disconnects after 10 minutes (i.e. 600 seconds)
        #"nfsvers=4.2" # not sure if needed but we can specify the specific version
      ];
    };
  };
}
