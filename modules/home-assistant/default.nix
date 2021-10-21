{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.home-assistant = mkEnableOption "Install and configure home assistant on this machine";

  config = mkIf cfg.home-assistant {
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensurePermissions = {
          "DATABASE hass" = "ALL PRIVILEGES";
        };
      }];
    };

    services.home-assistant = {
      enable = true;
      #package = (pkgs.home-assistant.override {
      #  extraPackages = py: with py; [ psycopg2 ];
      #});

      config = {
        # Provides some sane defaults and minimal dependencies
        default_config = { };
        recorder.db_url = "postgresql://@/hass";

        shelly = { };

        zeroconf = { default_interface = true; };
        # Basic settings for home-assistant
        homeassistant = with settings.home; {
          name = name;
          latitude = latitude;
          longitude = longitude;
          elevation = elevation;
          unit_system = unit_system;
          time_zone = timezone;
          #currency = currency;
          # external_url = "https://home.pablo.tools";
        };

        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "10.16.1.1"
          ];
        };

        frontend = { };
        "map" = { };
        shopping_list = { };
        logger.default = "info";
        sun = { };
        config = { };
        mobile_app = { };
        cloud = { };
        system_health = { };

        # Discover some devices automatically
        discovery = { };

        # Show some system health data
        system_health = { };

        # Enable support for tamota devices
        tasmota = { };

        # Led strip wifi controller, component needs to be listed explicitely in
        # extraComponents above
        # light = [{
        #   platform = "flux_led";
        #   automatic_add = true;
        #   devices = { "192.168.2.106" = { name = "flux_led"; }; };
        # }];

        # Fritzbox network traffic stats
        #sensor = [{ platform = "fritzbox_netmonitor"; }];

        # Metrics for prometheus
        # prometheus = {
        #   namespace = "hass";
        # };

        # Enable MQTT and configure it to use the mosquitto broker
        #mqtt = {
        #  broker = "192.168.2.84";
        #  port = "1883";
        #  username = "mosquitto";
        #  password = "mosquitto";
        #};

        # Enables a map showing the location of tracked devies
        map = { };

        # Track the sun
        sun = { };

        # Enable mobile app
        mobile_app = { };

        openweathermap = with settings.home; {
          api_key = "";
          name = name;
          mode = "onecall_hourly";
          longitude = longitude;
          elevation = elevation;

        };
        weather = { };

        # Enable configuration UI
        # config = { };

        # Enable support for tracking state changes over time
        history = { };

        # Purge tracked history after 10 days
        recorder.purge_keep_days = 10;

        # View all events in o logbook
        logbook = { };
      };
    };
  };
}

