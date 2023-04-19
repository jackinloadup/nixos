{ lib, config, pkgs, ... }:

let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.postgresql.enable {
    # Open port to nextwork
    networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];

    services.postgresql = {
      package = pkgs.postgresql_15;
      #extraPlugins = with pkgs.postgresql_15.pkgs; [ postgis pg_repack ];
      enableTCPIP = true;
      #authentication = pkgs.lib.mkOverride 10 ''
      #  local all root trust
      #'';
      # From http://pgconfigurator.cybertec.at/; https://git.darmstadt.ccc.de/maralorn/nixos-config/-/blob/master/nixos/roles/matrix-synapse/postgres-tuning.nix
      settings = {
        # Connectivity;
        max_connections = 100;
        superuser_reserved_connections = 3;
        # Memory Settings;
        shared_buffers = "1024 MB";
        work_mem = "32 MB";
        maintenance_work_mem = "320 MB";
        huge_pages = "off";
        effective_cache_size = "2 GB";
        effective_io_concurrency = 100; # concurrent IO only really activated if OS supports posix_fadvise function;
        random_page_cost = 1.25; # speed of random disk access relative to sequential access (1.0);
        # Monitoring;
        shared_preload_libraries = "pg_stat_statements,auto_explain"; # per statement resource usage stats & log explain statements for slow queries
        track_io_timing = "on"; # measure exact block IO times;
        track_functions = "pl"; # track execution times of pl-language procedures if any;
        # Replication;
        wal_level = "replica"; # consider using at least "replica";
        max_wal_senders = 0;
        synchronous_commit = "on";

        # Checkpointing: ;
        checkpoint_timeout = "15 min";
        checkpoint_completion_target = 0.9;
        max_wal_size = "1024 MB";
        min_wal_size = "512 MB";

        # WAL writing;
        wal_compression = "on";
        wal_buffers = -1; # auto-tuned by Postgres till maximum of segment size (16MB by default);
        wal_writer_delay = "200ms";
        wal_writer_flush_after = "1MB";

        # Background writer;
        bgwriter_delay = "200ms";
        bgwriter_lru_maxpages = 100;
        bgwriter_lru_multiplier = 2.0;
        bgwriter_flush_after = 0;

        # Parallel queries: ;
        max_worker_processes = 6;
        max_parallel_workers_per_gather = 3;
        max_parallel_maintenance_workers = 3;
        max_parallel_workers = 6;
        parallel_leader_participation = "on";

        # Advanced features ;
        enable_partitionwise_join = "on";
        enable_partitionwise_aggregate = "on";
        jit = "on";

        jit_above_cost = 100000;
        jit_inline_above_cost = 150000;
        jit_optimize_above_cost = 500000;

        # log slow queries
        log_min_duration_statement = 100;
        "auto_explain.log_min_duration" = 100;
      };
    };

    services.pgadmin = {
      enable = true;
    };

    services.postgresqlBackup = {
      enable = true;
      compression = "zstd";
      compressionLevel = 12;
      location = "/mnt/postgres";
    };
    #
    # Mount Nextcloud Storage
    system.fsPackages = [ pkgs.sshfs ];
    fileSystems.postgresqlBackup = {
      mountPoint = "/mnt/postgres";
      device = "postgres@truenas.home.lucasr.com:/mnt/storage/backed-up/postgres/";
      fsType = "sshfs";
      options = [
        "allow_other"          # for non-root access
        "_netdev"              # requires network to mount
        "x-systemd.automount"  # mount on demand

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
  };

}
