{ lib, pkgs, config, ... }:
with lib;
{
  imports = [];

  options.machine.bluetooth = mkEnableOption "Enable bluetooth";

  config = mkIf config.machine.bluetooth {
    hardware.bluetooth.enable = true;

    hardware.bluetooth.hsphfpd.enable = true; # High quality BT calls
    # hsphfpd fails if this is enabled https://github.com/NixOS/nixpkgs/issues/114222
    systemd.user.services.telephony_client.enable = false; # work around for above

    services.blueman.enable = true;
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
