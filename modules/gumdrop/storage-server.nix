{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.gumdrop.storageServer;
  settings = import ../../settings;
in {
  imports = [];

  options.gumdrop.storageServer = {
    enable = mkEnableOption "Setup connection to storage server";
    requiredForBoot = mkEnableOption "Require storage server connection to boot";
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
    mount = { name, mount ? "gumdrop/${name}", remoteMount ? "storage/${name}" } : if cfg.${name}
      then {
        "/mnt/${mount}" = {
          device = "freenas.home.lucasr.com:/mnt/${remoteMount}";
          fsType = "nfs";
          options = [
            "noauto" # lazy mounting
            "noatime"
            "nodiratime"
            "x-systemd.automount" # lazy mounting
            "x-systemd.idle-timeout=${toString cfg.idleTimeout}" # disconnects after 10 minutes (i.e. 600 seconds)
            #"nfsvers=4.2" # likely not needed. Client already negotiates version starting from newest
          ]
          # Don't try to connect until network is online. duh
          ++ optional cfg.requiredForBoot "x-systemd.after=freenas-lookup.service";
        };
      }
    else {};
  in mkIf cfg.enable {
    systemd.services = mkIf cfg.requiredForBoot {
      "freenas-lookup" = {
        enable = true;
        restartIfChanged = false;
        description = "Wait until freenas dns returns";
        after = [ "nss-lookup.target" ];
        #wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart =  "/bin/sh -c 'while ! ${pkgs.host}/bin/host freenas.home.lucasr.com; do sleep 1; done'";
          Type = "oneshot";
        };
      };
    };
    # https://nixos.wiki/wiki/NFS
    fileSystems = mkMerge [
      ( mount { name = "media"; } )
      ( mount { name = "roms"; } )
    ];

    # This service isn't needed for NFSv4. Needed pre v4
    services.rpcbind.enable = mkForce false;
  };
}
