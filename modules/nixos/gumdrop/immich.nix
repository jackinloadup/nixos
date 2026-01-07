{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf getExe;
  currentDatabase = config.services.immich.database.name;
  dbUser = config.services.immich.database.user;

  ftpUploadPath = "/mnt/gumdrop/printerScanShare/immich";
  immichUrl = "https://immich.lucasr.com";
in
{
  config = mkIf config.services.immich.enable {
    services.immich = {
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
    users.users.immich.extraGroups = [ "video" "render" "serviceftp" ];

    # FTP upload import service
    # Periodically uploads files from FTP directory into Immich, then deletes them
    systemd.services.immich-ftp-import = {
      description = "Import FTP uploads into Immich";
      after = [ "network-online.target" "immich-server.service" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.immich-cli ];
      serviceConfig = {
        Type = "oneshot";
        User = "immich";
        Group = "immich";
        ExecStart = pkgs.writeShellScript "immich-ftp-import" ''
          set -euo pipefail

          API_KEY=$(cat ${config.age.secrets.immich-api-key.path})

          # Check if there are any files to upload
          if [ -z "$(ls -A ${ftpUploadPath} 2>/dev/null)" ]; then
            echo "No files to import"
            exit 0
          fi

          echo "Importing files from ${ftpUploadPath}..."
          ${getExe pkgs.immich-cli} upload \
            --key "$API_KEY" \
            --url "${immichUrl}" \
            --delete \
            "${ftpUploadPath}"
        '';
      };
    };

    systemd.timers.immich-ftp-import = {
      description = "Run Immich FTP import periodically";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
        Persistent = true;
      };
    };
  };
}

