{ config, lib, ... }:
let
  inherit (lib) mkIf;
in {
  config = {
    networking.firewall.allowedTCPPorts = [
      1883 # mosquitto
      8080 # zigbee2mqtt
    ];

    services.home-assistant = {
      enable = true;
      openFirewall = true;
      #configWritable = true;

      extraComponents = [ "mobile_app" ];

      config = {
        sun = {};
        # sun.elevation = 247;
        # esphome = {}; # fails
        # camera = [];
        # discovery = {};
        # conversation = {};
        # history = {};
        # logbook = {};
        config = {};
        homeassistant = {
          name = "Home";
          #latitude = "!secret latitude";
          #longitude = "!secret longitude";
          #elevation = "!secret elevation";
          #unit_system = "metric";
          time_zone = "America/Chicago";
          auth_providers = [
            { type = "trusted_networks";
              trusted_networks = [ "10.16.1.0/24" "192.168.1.0/24"];
              allow_bypass_login = true;
            }
            { type = "homeassistant"; }
          ];
        };
        http = {
          #use_x_forwarded_for = true;
          #trusted_proxies = [
          #  "127.0.0.1"
          #  "::1"
          #];
          server_port = 8123;
          server_host = [
            "0.0.0.0"
            "::"
          ];
        };
        frontend = { };
        mobile_app = { };
        rest_command = {};
        api = {};
        mqtt = {};
        #mqtt = {
        #  keepalive = 60;
        #  protocol = 3.1;

        #  # Can't be configured in config anymore, very disapointing
        #  #broker = "127.0.0.1";
        #  #port = 1883;

        #  #username = "mosquitto";
        #  #password = "mosquitto";

        #  discovery = true; #enable esphome discovery
        #  discovery_prefix = "homeassistant";
        #  client_id = "home-assistant";

        #  #birth_message = {
        #  #  topic = "${prefix}/hass/tele/LWT";
        #  #  payload = "Online";
        #  #  qos = 1;
        #  #  retain = true;
        #  #};
        #  #will_message = {
        #  #  topic = "${prefix}/hass/tele/LWT";
        #  #  payload = "Offline";
        #  #  qos = 1;
        #  #  retain = true;
        #  #};
        #};
        logger = {
          default = "warning";
          logs = {
            "mqtt" = "debug";
          };
        };
      };
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        homeassistant = mkIf config.services.home-assistant.enable {
           # Optional: Home Assistant discovery topic (default: shown below)
           # Note: should be different from [MQTT base topic](../mqtt.md) to prevent errors in HA software
           discovery_topic = "homeassistant";
           # Optional: Home Assistant status topic (default: shown below)
           # Note: in addition to the `status_topic`, 'homeassistant/status' will also be used
           status_topic = "hass/status";
        };
        frontend = {
          port = 8080;
          host = "0.0.0.0";
        };
        permit_join = false;
        serial = {
          port = "/dev/ttyUSB0";
        };
        mqtt = {
          base_topic = "zigbee2mqtt";
          server = "mqtt://127.0.0.1:1883";
          user = "mosquitto";
          password = "mosquitto";
        };
        advanced = {
          # Optional: ZigBee pan ID (default: shown below)
          # Setting pan_id: GENERATE will make Zigbee2MQTT generate a new panID on next startup
          #pan_id =  "0x1a62";
          pan_id =  4695;
          # Optional: Zigbee extended pan ID, GENERATE will make Zigbee2MQTT generate a new extended panID on next startup (default: shown below)
          #ext_pan_id = ["0xDD" "0xDD" "0xDD" "0xDD" "0xDD" "0xDD" "0xDD" "0xDD"];
          ext_pan_id = [3422 9650 3893 1478 2004 8834 4356 9974];
          # Optional: ZigBee channel, changing requires re-pairing of all devices. (Note: use a ZLL channel: 11, 15, 20, or 25 to avoid Problems)
          # (default: 11)
          channel = 11;
          # Optional: network encryption key
          # GENERATE will make Zigbee2MQTT generate a new network key on next startup
          # Note: changing requires repairing of all devices (default: shown below)
          network_key = [ 170 31 25 137 89 121 173 150 30 52 24 76 88 107 192 113 ];
          #network_key = "GENERATE";
        };

      };
    };

    systemd.services.home-assistant = {
      serviceConfig = {
        DeviceAllow = [
          "/dev/ttyUSB0"
        ];
      };
    };

    # Enable mosquitto MQTT broker
    services.mosquitto = {
      enable = true;
      # unsure if keepalive affects power consumption on client devices
      settings.max_keepalive = 300; # 5 minutes

      listeners = [
        {
          port = 1883;
          users = {
            # No real authentication needed here, since the local network is
            # trusted.
            # TODO make this more secure
            mosquitto = {
              acl = ["readwrite #"];
              password = "mosquitto";
            };
          };
        }
      ];
    };

    # TODO submit upstream?
    systemd.services.mosquitto.after = ["network-online.target"];
  };
}
