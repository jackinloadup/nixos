{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  ifGraphical = config.machine.sizeTarget > 1;
in {
  config = mkIf config.hardware.bluetooth.enable {
    # this is likely only needed on interactive computers?
    # https://github.com/bluez/bluez/issues/319#issuecomment-1795890729
    boot.kernelParams = [
      "btusb.enable_autosuspend=n" # Possible fix for bluetooth not connecting
    ];

    hardware.bluetooth = {
      # Change package to enable controller support
      # https://github.com/NixOS/nixpkgs/pull/52168
      # https://functor.tokyo/blog/2018-12-20-playstation-bluetooth-controller
      package = pkgs.bluez;
      disabledPlugins = [
        "sap" # SIM Access Profile fails and isn't needed
        "vcp" # these three were failing to init
        "mcp"
        "bap"
      ];
      hsphfpd.enable = false; # Handled in Wireplumer
      settings = {
        General = {
          FastConnectable = "true"; # This seems to be the magic sauce
          JustWorksRepairing = "always";
          #MultiProfile = "multiple";
          DiscoverableTimeout = 0;

          # Allows showing battery of bluetooth devices
          # Enables D-Bus experimental interfaces
          # Possible values: true or false
          #Experimental = true

          # Unsure if the following location is valid for this setting
          # or what can be in this setting
          Enable = "Source,Sink,Headset,Gateway,Control,Socket,Media";

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

    environment.systemPackages = [
      pkgs.bluetuith
      pkgs.bluetui
    ];
    hardware.bluetooth.input = {
      General = {
        IdleTimeout = true;
      };
    };

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
    # media-session gone in NIXOS 23.05
    #services.pipewire = {
    #  # High quality BT calls
    #  media-session.config.bluez-monitor.rules = [
    #    {
    #      # Matches all cards
    #      matches = [{"device.name" = "~bluez_card.*";}];
    #      actions = {
    #        "update-props" = {
    #          "bluez5.auto-connect" = ["hfp_hf" "hsp_hs" "a2dp_sink"];
    #          # mSBC is not expected to work on all headset + adapter combinations.
    #          "bluez5.msbc-support" = true;
    #          # SBC-XQ is not expected to work on all headset + adapter combinations.
    #          "bluez5.sbc-xq-support" = true;
    #        };
    #      };
    #    }
    #    {
    #      matches = [
    #        # Matches all sources
    #        {"node.name" = "~bluez_input.*";}
    #        # Matches all outputs
    #        {"node.name" = "~bluez_output.*";}
    #      ];
    #      actions = {
    #        # prevent poping sound when devices are stopped and started
    #        # may not happen to all devices so maybe check per machine?
    #        "node.pause-on-idle" = false;
    #      };
    #    }
    #  ];
    #};
  };
}
