{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
  mountPoint = "/mnt/nextcloud";
  currentDatabase = "nextcloud29";
in {
  config = mkIf config.services.nextcloud.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.nextcloud = {
      package = pkgs.nextcloud29;
      #extraApps = with pkgs.nextcloud26Packages.apps; {
      #  inherit mail news contacts;
      #};

      hostName = "nextcloud.lucasr.com";
      https = true;
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit calendar contacts notes onlyoffice tasks cookbook qownnotesapi;
        # Custom app example.
#        socialsharing_telegram = pkgs.fetchNextcloudApp rec {
#          url =
#            "https://github.com/nextcloud-releases/socialsharing/releases/download/v3.0.1/socialsharing_telegram-v3.0.1.tar.gz";
#          license = "agpl3";
#          sha256 = "sha256-8XyOslMmzxmX2QsVzYzIJKNw6rVWJ7uDhU1jaKJ0Q8k=";
#        };
      };
      home = "${mountPoint}/lib";
      datadir = "${mountPoint}/data";

      #globalProfiles = false; # does not exist anymore

      caching = {
        redis = true;
        apcu = true;
      };
      settings = {
        trusted_proxies = ["127.0.0.1/32" "10.16.1.0/24" "10.100.0.0/24"];
        csrf.optout = [ "/Nextcloud-android/" ];
        default_phone_region = "US";

        redis = {
          host = "/run/redis-nextcloud/redis.sock";
          port = 0;
        };
        memcache = {
          local = "\\OC\\Memcache\\Redis";
          distributed = "\\OC\\Memcache\\Redis";
          locking = "\\OC\\Memcache\\Redis";
        };
      };
      config = {

        dbhost = "postgres.home.lucasr.com:5432";
        #dbhost = "127.0.0.1:5432";
        dbname = currentDatabase;
        dbtype = "pgsql"; # sqlite, pgsql, mysql
        #dbpassFile = "";
        #dbtableprefix
        adminuser = "root";
        #adminpassFile = "/etc/nextcloud-admin-pass";
        objectstore.s3 = {
          enable = false;
          bucket = "bucketname";

          # The following options are for non amazon s3 implimentations
          #hostname =
          #port =
          #region =
          #usePathStyle = "";

          # The full path to a file that contains the access secret. Must be readable by user nextcloud.
          #secretFile = "/var/nextcloud-objectstore-s3-secret";
        };
      };

      # Suggested by Nextcloud's health check.
      phpOptions."opcache.interned_strings_buffer" = "16";
      phpOptions."opcache.revalidate_freq" = "60";
      phpOptions."opcache.jit" = "1255";
      phpOptions."opcache.jit_buffer_size" = "8M";
    };

    services.redis.servers.nextcloud = {
      enable = true;
      user = "nextcloud";
      port = 0;
    };

    users.users.nextcloud.uid = 20000;
    users.groups.nextcloud.gid = 20000;

    # Mount Nextcloud Storage
    system.fsPackages = [pkgs.sshfs];
    fileSystems.nextcloud = {
      inherit mountPoint;
      device = "nextcloud@truenas.home.lucasr.com:/mnt/storage/backed-up/nextcloud/";
      fsType = "sshfs";
      options = [
        "allow_other" # for non-root access
        "_netdev" # requires network to mount
        "x-systemd.automount" # mount on demand

        # The ssh key must not be encrypted, have strict
        # permissions (like 600) and owned by root.
        "IdentityFile=/etc/ssh/ssh_host_ed25519_key"

        # Handle connection drops better
        "ServerAliveInterval=15"
        "reconnect"

        # You can specify some of the ssh_config(5)
        # options, for example:
        #"ProxyJump=bastion@example.com"
        #"Port=22"

        # You can also change the ssh command.
        # Note: in any option spaces must be
        # escaped because it goes to /etc/fstab,
        # a table of space-separated fields.
        #(builtins.replaceStrings [" "] ["\\040"]
        #  "ssh_command=${pkgs.openssh}/bin/ssh -v -L 8080:localhost:80")

        # Uncomment this if you're having a hard time
        # figuring why mounting is failing.
        #"debug"
      ];
    };

    # ensure that postgres is running *before* running the setup
    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service" "mnt-nextcloud.mount"];
    };

    # response to depriciation
    # https://nixos.org/manual/nixos/stable/#module-postgresql
    # https://stackoverflow.com/questions/22483555/postgresql-give-all-permissions-to-a-user-on-a-postgresql-database
    #systemd.services.postgresql.postStart = lib.mkAfter ''
    #  $PSQL service1 -c 'GRANT ALL PRIVILEGES ON DATABASE "nextcloud26" TO "nextcloud"'
    #  $PSQL service1 -c 'GRANT ALL PRIVILEGES ON DATABAES "postgres" TO "nextcloud"'
    #'';

    services.postgresql = {
      enable = true;
      ensureDatabases = [ currentDatabase ];
      ensureUsers = [
        {
          name = "nextcloud";
          # Depriciated
          #ensurePermissions."database.nextcloud26" = "ALL PRIVILEGES";
          #ensurePermissions."database.postgres" = "ALL PRIVILEGES";
        }
      ];
      # allowing whole subnet as marulk uses dhcp
      authentication = ''
        host ${currentDatabase} nextcloud 10.16.1.0/24 md5
        host postgres nextcloud 10.16.1.0/24 md5
        host postgres nextcloud 127.0.0.1/32 md5
      '';
    };
    services.postgresqlBackup.databases = [ currentDatabase ];
        # Nightly database backups.
    #postgresqlBackup = {
    #  enable = true;
    #  startAt = "*-*-* 01:15:00";
    #};

    #services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    #  addSSL = true;
    #  enableACME = true;
    #};
    #security.acme = {
    #  defaults.email = "lriutzel@gmail.com";
    #  acceptTerms = true;
    #};

    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS Challenege
      extraConfig = ''
        fastcgi_connect_timeout 10m;
        fastcgi_read_timeout 10m;
        fastcgi_send_timeout 10m;
      '';

    };

    security.acme = {
    #  acceptTerms = true;
      certs = {
        ${config.services.nextcloud.hostName}.email = "lriutzel@gmail.com";
      };
    };

  };


}
