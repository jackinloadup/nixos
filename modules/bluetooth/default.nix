{ lib, pkgs, config, ... }:
with lib;
{
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
          MultiProfile = "multiple";
          IdleTimeout = 5; # 5 Minutes
          Discoverable = "true";
          DiscoverableTimeout = 0;
        };
        Policy = {
          AutoEnable = true;
        };
        "64:D4:BD:6A:9C:8E" = {
          IdleTimeout = 1; # 1 Minutes
        #};
        #"PS3 Remote Map" = {
          "0x16" = "KEY_ESC";            # EJECT = exit
          "0x64" = "KEY_MINUS";          # AUDIO = cycle audio tracks
          "0x65" = "KEY_W";              # ANGLE = cycle zoom mode
          "0x63" = "KEY_T";              # SUBTITLE = toggle subtitles
          "0x0f" = "KEY_DELETE";         # CLEAR = delete key
          "0x28" = "KEY_F8";             # /TIME = toggle through sleep
          "0x00" = "KEY_1";              # NUM-1
          "0x01" = "KEY_2";              # NUM-2
          "0x02" = "KEY_3";              # NUM-3
          "0x03" = "KEY_4";              # NUM-4
          "0x04" = "KEY_5";              # NUM-5
          "0x05" = "KEY_6";              # NUM-6
          "0x06" = "KEY_7";              # NUM-7
          "0x07" = "KEY_8";              # NUM-8
          "0x08" = "KEY_9";              # NUM-9
          "0x09" = "KEY_0";              # NUM-0
          "0x81" = "KEY_F2";             # RED = red
          "0x82" = "KEY_F3";             # GREEN = green
          "0x80" = "KEY_F4";             # BLUE = blue
          "0x83" = "KEY_F5";             # YELLOW = yellow
          "0x70" = "KEY_I";              # DISPLAY = show information
          "0x1a" = "KEY_S";              # TOP MENU = show guide
          "0x40" = "KEY_M";              # POP UP/MENU = menu
          "0x0e" = "KEY_ESC";            # RETURN = back/escape/cancel
          "0x5c" = "KEY_R";              # TRIANGLE/OPTIONS = cycle through recording options
          "0x5d" = "KEY_ESC";            # CIRCLE/BACK = back/escape/cancel
          "0x5f" = "KEY_A";              # SQUARE/VIEW = Adjust Playback timestretch
          "0x5e" = "KEY_ENTER";          # CROSS = select
          "0x54" = "KEY_UP";             # UP = Up/Skip forward 10 minutes
          "0x56" = "KEY_DOWN";           # DOWN = Down/Skip back 10 minutes
          "0x57" = "KEY_LEFT";           # LEFT = Left/Skip back 5 seconds
          "0x55" = "KEY_RIGHT";          # RIGHT = Right/Skip forward 30 seconds
          "0x0b" = "KEY_ENTER";          # ENTER = select
          "0x5a" = "KEY_F10";            # L1 = volume down
          "0x58" = "KEY_J";              # L2 = decrease the play speed
          "0x51" = "KEY_HOME";           # L3 = commercial skip previous
          "0x5b" = "KEY_F11";            # R1 = volume up
          "0x59" = "KEY_U";              # R2 = increase the play speed
          "0x52" = "KEY_END";            # R3 = commercial skip next
          "0x43" = "KEY_F9";             # PS button = mute
          "0x50" = "KEY_M";              # SELECT = menu (as per PS convention)
          "0x53" = "KEY_ENTER";          # START = select / Enter (matches terminology in mythwelcome)
          "0x30" = "KEY_PAGEUP";         # PREV = jump back (default 10 minutes)
          "0x76" = "KEY_J";              # INSTANT BACK (newer RCs only) = decrease the play speed
          "0x75" = "KEY_U";              # INSTANT FORWARD (newer RCs only) = increase the play speed
          "0x31" = "KEY_PAGEDOWN";       # NEXT = jump forward (default 10 minutes)
          "0x33" = "KEY_COMMA";          # SCAN BACK =  decrease scan forward speed / play
          "0x32" = "KEY_P";              # PLAY = play/pause
          "0x34" = "KEY_DOT";            # SCAN FORWARD decrease scan backard speed / increase playback speed"; 3x, 5, 10, 20, 30, 60, 120, 180
          "0x60" = "KEY_LEFT";           # FRAMEBACK = Left/Skip back 5 seconds/rewind one frame
          "0x39" = "KEY_P";              # PAUSE = play/pause
          "0x38" = "KEY_P";              # STOP = play/pause
          "0x61" = "KEY_RIGHT";          # FRAMEFORWARD = Right/Skip forward 30 seconds/advance one frame
          "0xff" = "KEY_MAX";
        };
      };
    };

    hardware.bluetooth.hsphfpd.enable = true; # High quality BT calls
    # hsphfpd fails if this is enabled https://github.com/NixOS/nixpkgs/issues/114222
    systemd.user.services.telephony_client.enable = false; # work around for above

    services.blueman.enable = true;

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
