{ lib
, config
, pkgs
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types mkDefault;
  inherit (builtins) attrNames readDir filter;

  cfg = config.machine.monitoring;

  # Get list of machines from the machines directory
  allMachines = attrNames (readDir ../../../machines);

  # Filter to only real machines (exclude minimal, gumdrop-nas, etc. if needed)
  monitoredMachines = filter (m: m != "minimal" && m != "gumdrop-nas") allMachines;

  # Domain for machine hostnames
  domain = "home.lucasr.com";

  # Generate scrape targets for VictoriaMetrics
  scrapeTargets = map (machine: "${machine}.${domain}:9100") monitoredMachines;

  # vmagent scrape configuration
  vmagentConfig = pkgs.writeText "vmagent.yml" ''
    global:
      scrape_interval: 15s
      scrape_timeout: 10s

    scrape_configs:
      - job_name: 'node'
        static_configs:
          - targets:
    ${lib.concatMapStringsSep "\n" (t: "          - '${t}'") (scrapeTargets ++ cfg.server.extraScrapeTargets)}
        relabel_configs:
          - source_labels: [__address__]
            regex: '([^:]+)\.home\.lucasr\.com:.*'
            target_label: instance
            replacement: '$1'
  '';

  # Grafana dashboards fetched from grafana.com
  # Using revision IDs for reproducibility
  grafanaDashboards = pkgs.runCommand "grafana-dashboards" { } ''
    mkdir -p $out

    # Node Exporter Full (ID: 1860, rev: 37)
    cp ${pkgs.fetchurl {
      url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
      hash = "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM=";
      name = "node-exporter-full.json";
    }} $out/node-exporter-full.json

    # VictoriaMetrics single-node (ID: 10229, rev: 35)
    cp ${pkgs.fetchurl {
      url = "https://grafana.com/api/dashboards/10229/revisions/35/download";
      hash = "sha256-jDSQLKexiYh6Fx099NwYC/8F3nl2KC3psHLpUcjpcjk=";
      name = "victoriametrics.json";
    }} $out/victoriametrics.json
  '';

in
{
  options.machine.monitoring = {
    enable = mkEnableOption "metrics collection via node_exporter";

    server = {
      enable = mkEnableOption "central monitoring server (VictoriaMetrics + Grafana)";

      retentionPeriod = mkOption {
        type = types.str;
        default = "30d";
        description = "How long to retain metrics data";
      };

      grafanaPort = mkOption {
        type = types.port;
        default = 3000;
        description = "Port for Grafana web interface";
      };

      victoriaMetricsPort = mkOption {
        type = types.port;
        default = 8428;
        description = "Port for VictoriaMetrics";
      };

      extraScrapeTargets = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional scrape targets (e.g., 'truenas.home.lucasr.com:9100')";
        example = [ "truenas.home.lucasr.com:9100" "mikrotik.home.lucasr.com:9100" ];
      };
    };
  };

  config = lib.mkMerge [
    # Client configuration - node_exporter on all monitored machines
    (mkIf cfg.enable {
      services.prometheus.exporters.node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "processes"
        ];
        # Listen on all interfaces so the central server can scrape
        listenAddress = "0.0.0.0";
      };

      # Open firewall for node_exporter
      networking.firewall.allowedTCPPorts = [ 9100 ];
    })

    # Server configuration - VictoriaMetrics + Grafana on central node
    (mkIf cfg.server.enable {
      # Also enable node_exporter on the server itself
      machine.monitoring.enable = mkDefault true;

      # VictoriaMetrics - lightweight Prometheus-compatible TSDB
      services.victoriametrics = {
        enable = true;
        listenAddress = "127.0.0.1:${toString cfg.server.victoriaMetricsPort}";
        inherit (cfg.server) retentionPeriod;
        extraOptions = [
          "-selfScrapeInterval=15s"
        ];
      };

      # vmagent for scraping metrics and sending to VictoriaMetrics
      systemd.services.vmagent = {
        description = "VictoriaMetrics Agent";
        after = [ "network.target" "victoriametrics.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          StateDirectory = "vmagent";
          WorkingDirectory = "/var/lib/vmagent";
          ExecStart = ''
            ${pkgs.victoriametrics}/bin/vmagent \
              -promscrape.config=${vmagentConfig} \
              -remoteWrite.url=http://127.0.0.1:${toString cfg.server.victoriaMetricsPort}/api/v1/write \
              -remoteWrite.tmpDataPath=/var/lib/vmagent
          '';
          Restart = "always";
          RestartSec = "5s";
        };
      };

      # Grafana for visualization
      services.grafana = {
        enable = true;

        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = cfg.server.grafanaPort;
            domain = "grafana.${domain}";
            root_url = "https://grafana.${domain}/";
          };

          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
          };

          security = {
            allow_embedding = true;
            cookie_secure = true;
          };

          # Required when behind reverse proxy
          server.enforce_domain = false;
        };

        provision = {
          enable = true;

          datasources.settings.datasources = [
            {
              name = "VictoriaMetrics";
              type = "prometheus";
              url = "http://127.0.0.1:${toString cfg.server.victoriaMetricsPort}";
              isDefault = true;
              editable = false;
            }
          ];

          dashboards.settings.providers = [
            {
              name = "default";
              options.path = grafanaDashboards;
              disableDeletion = true;
            }
          ];
        };
      };

      # Nginx reverse proxy for Grafana
      services.nginx.virtualHosts."grafana.${domain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.server.grafanaPort}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      # Nginx for VictoriaMetrics UI (useful for debugging/queries)
      services.nginx.virtualHosts."metrics.${domain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.server.victoriaMetricsPort}";
        };
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];
    })
  ];
}
