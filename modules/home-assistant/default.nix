{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [];


  options.machine.home-assistant = mkEnableOption "Install and configure home assistant on this machine";

  config = mkIf cfg.home-assistant {
    #services.postgresql = {
    #  enable = true;
    #  ensureDatabases = [ "hass" ];
    #  ensureUsers = [{
    #    name = "hass";
    #    ensurePermissions = {
    #      "DATABASE hass" = "ALL PRIVILEGES";
    #    };
    #  }];
    #};

    # Needed for some integrations 
    # - Not sure which ones but used for chirp which does radio stuff
    # - So maybe it's used for some radio devices
    users.users.lriutzel.extraGroups = [ "dialout" ];

    # Open port for mqtt
    networking.firewall = {

      allowedTCPPorts = [
        1883 # mosquitto
        5900 # spice for hass vm
        8123 # hass web ui
        4357 # hass ovserver url
      ];

      # Expose home-assitant over wireguard
      #interfaces.wg0.allowedTCPPorts = [ 8123 ]; # Artifact of future wireguard ideas
    };

    # Enable mosquitto MQTT broker
    services.mosquitto = with settings; {
      enable = true;

      listeners = [
        {
          port = 1883;
          users = {
            # No real authentication needed here, since the local network is
            # trusted.
            # TODO make this more secure
            mosquitto = {
              acl = [ "readwrite #" ];
              password = "mosquitto";
            };
          };
        }
      ];
    };

    # TODO submit upstream?
    systemd.services.mosquitto.after = [ "network-online.target" ];
  };
}

