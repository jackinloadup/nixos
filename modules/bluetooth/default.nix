{ lib, pkgs, config, ... }:
with lib;
let
  ifGraphical = if (config.machine.sizeTarget > 1) then true else false;
in {
  imports = [];

  options.machine.bluetooth = mkEnableOption "Enable bluetooth";

  config = mkIf config.machine.bluetooth {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          FastConnectable = "true";
          JustWorksRepairing = "always";
          #MultiProfile = "multiple";
          DiscoverableTimeout = 0;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
    environment.etc."bluetooth/input.conf".text = ''
[General]
IdleTimeout=1
'';

    hardware.bluetooth.hsphfpd.enable = ifGraphical; # High quality BT calls
    # hsphfpd fails if this is enabled https://github.com/NixOS/nixpkgs/issues/114222
    systemd.user.services.telephony_client.enable = false; # work around for above

    services.blueman.enable = ifGraphical;

    # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
    services.pipewire = {
      # High quality BT calls
      media-session.config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
              # SBC-XQ is not expected to work on all headset + adapter combinations.
              "bluez5.sbc-xq-support" = true;
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
