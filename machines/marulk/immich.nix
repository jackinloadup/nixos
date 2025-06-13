{ config, lib, ...}:
let
  inherit (lib) mkDefault;
  currentDatabase = config.services.immich.database.name;
  dbUser = config.services.immich.database.user;
in {
  config = {
    services.immich = {
      enable = true;
      host = "127.0.0.1"; # where to listen
      settings.server.externalDomain = "https://immich.lucasr.com";
      database.host = "postgres.home.lucasr.com";
      mediaLocation = "/mnt/gumdrop/backup/immich";
      #accelerationDevices = [ "/dev/dri/renderD128" ];
    };

    services.postgresql = {
      # allowing whole subnet as marulk uses dhcp
      authentication = ''
        host ${currentDatabase} ${dbUser} 10.16.1.0/24 md5
      '';
      # host postgres ${dbUser} 10.16.1.0/24 md5
      # host postgres ${dbUser} 127.0.0.1/32 md5
    };
    services.postgresqlBackup.databases = [ currentDatabase ];

    services.nginx.virtualHosts."immich.lucasr.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.immich.port}/";
        proxyWebsockets = true;
      };
    };
  };
}

