{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption mkMerge mkForce types;
  cfg = config.gumdrop.storageServer;
  settings = import ../../../settings;
  address = "truenas.home.lucasr.com";
in {
  imports = [];

  options.gumdrop.storageServer = {
    enable = mkEnableOption "Setup connection to storage server";
    idleTimeout = mkOption {
      type = types.int;
      default = 600;
      example = 300;
      description = "Disconnect after the connection is idle for x seconds";
    };
    media = mkEnableOption "Mount media share";
    roms = mkEnableOption "mount roms share";
    software = mkEnableOption "mount software share";
  };

  config = let
    mount = {
      name,
      mount ? "gumdrop/${name}",
      remoteMount ? "storage/${name}",
    }:
      if cfg.${name}
      then {
        "/mnt/${mount}" = {
          device = "${address}:/mnt/${remoteMount}";
          fsType = "nfs";
          options = [
            "noauto" # lazy mounting
            "noatime"
            "nodiratime"
            "x-systemd.automount" # lazy mounting
            "x-systemd.idle-timeout=${toString cfg.idleTimeout}" # disconnects after 10 minutes (i.e. 600 seconds)
            #"nfsvers=4.2" # likely not needed. Client already negotiates version starting from newest
          ];
        };
      }
      else {};
  in
    mkIf cfg.enable {
      # https://nixos.wiki/wiki/NFS
      fileSystems = mkMerge [
        (mount {name = "media";})
        (mount {name = "roms";})
      ];

      # This service isn't needed for NFSv4. Needed pre v4
      services.rpcbind.enable = mkForce false;
    };
}
