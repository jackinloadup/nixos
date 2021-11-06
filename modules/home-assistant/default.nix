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

    # Needed for some integrations
    users.users.lriutzel.extraGroups = [ "dialout" ];

    # Open port for mqtt
    networking.firewall = {

      allowedTCPPorts = [ 1883 8123 ];

      # Expose home-assitant over wireguard
      interfaces.wg0.allowedTCPPorts = [ 8123 ];
    };

   # Enable mosquitto MQTT broker
   services.mosquitto = {
     enable = true;

     checkPasswords = true;

     # Mosquitto is only listening on the local IP, traffic from outside is not
     # allowed.
     host = "10.16.1.11";
     port = 1883;
     users = {
       # No real authentication needed here, since the local network is
       # trusted.
       mosquitto = {
         acl = [ "pattern readwrite #" ];
         password = "mosquitto";
       };
     };
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

        zeroconf = { };
        # Basic settings for home-assistant
        homeassistant = with settings.home; {
          name = name;
          latitude = latitude;
          longitude = longitude;
          elevation = elevation;
          unit_system = unit_system;
          time_zone = timezone;
          currency = currency;
          # external_url = "https://home.pablo.tools";
          auth_providers = [
            {
              type = "trusted_networks";
              trusted_networks = [
                "10.16.1.0/24"
                "fd00::/8"
              ];
              #trusted_users = {
              #  "10.16.1.11" = "lucas";
              #};
            }
            {
              type = "homeassistant";
            }
          ];
        };

        http = {
          #use_x_forwarded_for = true;
          #trusted_proxies = [
          #  "10.16.1.1"
          #];
          cors_allowed_origins = [
            "http://10.16.1.11:8123/"
          ];
          server_host = "0.0.0.0";
        };

        frontend = { };
        "map" = { };
        shopping_list = { };
        logger.default = "info";
        sun = { };
        config = { };
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

        #media_player:
        # - platform: yamaha
        #   host: 192.168.0.10
        #   source_ignore:
        #     - "AUX"
        #     - "HDMI6"
        #   source_names:
        #     HDMI1: "ChromeCast"
        #     AV4: "Vinyl"
        #   zone_ignore:
        #     - "Zone_2"
        #   zone_names:
        #     Main_Zone: "Family Room"

        # Enable MQTT and configure it to use the mosquitto broker
        mqtt = {
          broker = "10.16.1.11";
          port = "1883";
          username = "mosquitto";
          password = "mosquitto";
        };

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

