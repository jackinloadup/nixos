{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
  mountPoint = "/mnt/nextcloud";
  currentDatabase = "nextcloud26";
in {
  config = mkIf config.services.nextcloud.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.nextcloud = {
      package = pkgs.nextcloud26;
      #extraApps = with pkgs.nextcloud26Packages.apps; {
      #  inherit mail news contacts;
      #};

      hostName = "nextcloud.home.lucasr.com";
      home = "${mountPoint}/lib";
      datadir = "${mountPoint}/data";

      globalProfiles = false;
      enableBrokenCiphersForSSE = false;

      caching = {
        redis = true;
        apcu = true;
      };
      extraOptions = {
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
        defaultPhoneRegion = "US";

        dbhost = "postgres.home.lucasr.com";
        dbname = currentDatabase;
        dbport = 5432;
        dbtype = "pgsql"; # sqlite, pgsql, mysql
        #dbpassFile = "";
        #dbtableprefix
        adminuser = "root";
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
      after = ["postgresql.service"];
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["nextcloud26"];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions."DATABASE \"nextcloud26\"" = "ALL PRIVILEGES";
          ensurePermissions."DATABASE \"postgres\"" = "ALL PRIVILEGES";
        }
      ];
      authentication = ''
        host nextcloud26 nextcloud 10.16.1.11/32 md5
        host postgres nextcloud 10.16.1.11/32 md5
      '';
    };
    services.postgresqlBackup.databases = ["nextcloud26"];
    #services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    #  addSSL = true;
    #  enableACME = true;
    #};
    #security.acme = {
    #  defaults.email = "lriutzel@gmail.com";
    #  acceptTerms = true;
    #};
  };
}
