{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  ifGraphical = config.machine.sizeTarget > 1;
in {
  config = mkIf config.hardware.bluetooth.enable {
    hardware.bluetooth = {
      disabledPlugins = [ "sap" ]; # SIM Access Profile fails and isn't needed
      hsphfpd.enable = false; # Handled in Wireplumer
      settings = {
        General = {
          FastConnectable = "true";
          JustWorksRepairing = "always";
          #MultiProfile = "multiple";
          DiscoverableTimeout = 0;
          # Enables D-Bus experimental interfaces
          # Possible values: true or false
          #Experimental = true

          # Enables kernel experimental features, alternatively a list of UUIDs
          # can be given.
          # Possible values: true,false,<UUID List>
          # Possible UUIDS:
          # Defaults to false.
          #KernelExperimental = true
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    environment.systemPackages = [ pkgs.bluetuith ];
    environment.etc."bluetooth/input.conf".text = ''
[General]
IdleTimeout=1
'';
# I can't seem to find offical documentation for what can be in these files
# Enable field is under testing
    environment.etc."bluetooth/audio.conf".text = ''
[General]
AutoConnect=true
Enable=Source,Sink,Headset,Gateway,Control,Socket,Media
'';

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
