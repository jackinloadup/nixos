{ lib, pkgs, config, ... }:
with lib;
{
  imports = [];

  options.machine.bluetooth = mkEnableOption "Enable steam game platform";

  config = mkIf config.machine.bluetooth {
    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      hsphfpd.enable = true; # High quality BT calls
    };

    services.pipewire = {
      # High quality BT calls
      media-session.config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            # prevent poping sound when devices are stopped and started
            # may not happen to all devices so maybe check per machine?
            "node.pause-on-idle" = false;
          };
        }
      ];
    };
  };
}
