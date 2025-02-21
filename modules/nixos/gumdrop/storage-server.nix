{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption mkMerge mkForce types optional;
  cfg = config.gumdrop.storageServer;
  settings = import ../../../settings;
  address = "truenas.home.lucasr.com";
in {
  imports = [];

  # TODO - make nfs more secure by limiting to authenticated network or changing
  # to an authenticated transport

  # once host ips are known, the nfs mount could specify clientaddr to force
  # connection over wireguard. Currently nfs isn't choosing that interface to
  # use. https://serverfault.com/questions/841976/how-to-specify-ipv6-address-to-use-while-mounting-nfs
  options.gumdrop.storageServer = {
    enable = mkEnableOption "Setup connection to storage server";
    idleTimeout = mkOption {
      type = types.int;
      default = 600;
      example = 300;
      description = "Disconnect after the connection is idle for x seconds";
    };
    family = mkEnableOption "Mount family share";
    media = mkEnableOption "Mount media share";
    roms = mkEnableOption "mount roms share";
    backup = mkEnableOption "mount backup";
    software = mkEnableOption "mount software share";
    printerScanShare = mkEnableOption "mount printer scan share";
  };

  config = let
    mount = {
      name,
      path,
      mount ? "gumdrop/${name}",
      remoteMount ? "storage/${path}"
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
            "nolock"
            "x-systemd.automount" # lazy mounting
            "x-systemd.idle-timeout=${toString cfg.idleTimeout}" # disconnects after 10 minutes (i.e. 600 seconds)
            #"nfsvers=4.2" # likely not needed. Client already negotiates version starting from newest
          ];
        };
      }
      else {};
  in
    mkIf cfg.enable {
      ## https://nixos.wiki/wiki/NFS
      fileSystems = mkMerge [
        (mount {name = "media"; path = "media";})
        (mount {name = "roms"; path = "roms";})
        (mount {name = "backup"; path = "backed-up";})
        (mount {name = "family"; path = "backed-up/family";})
        (mount {name = "printerScanShare"; path = "backed-up/printerScanShare";})
      ];

      # This service isn't needed for NFSv4. Needed pre v4
      services.rpcbind.enable = mkForce false;

      home-manager.sharedModules = [{
        gtk.gtk3.bookmarks = [ ]
        ++ optional cfg.media "file:///mnt/gumdrop/media Media"
        ++ optional cfg.roms "file:///mnt/gumdrop/roms Roms"
        ++ optional cfg.backup "file:///mnt/gumdrop/backup Backup"
        ++ optional cfg.family "file:///mnt/gumdrop/family Family";
      }];
    };
}
