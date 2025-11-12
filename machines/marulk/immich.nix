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
      settings = {
        server.externalDomain = "https://immich.lucasr.com";
        storageTemplate = {
          enabled = true;
          hashVerificationEnabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
        #newVersionCheck.enable = false;
      };
      database.host = "postgres.home.lucasr.com";
      mediaLocation = "/mnt/gumdrop/backup/immich";
      # `null` will give access to all devices.
      # You may want to restrict this by using something like `[ "/dev/dri/renderD128" ]`
      accelerationDevices = null;
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
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };

    };

    # https://wiki.nixos.org/wiki/Immich#Enabling_Hardware_Accelerated_Video_Transcoding
    systemd.services."immich-server".serviceConfig.PrivateDevices = lib.mkForce false;
    users.users.immich.extraGroups = [ "video" "render" ];
  };
}

