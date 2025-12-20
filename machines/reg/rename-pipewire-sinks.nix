{ ... }: {
  services.pipewire.wireplumber.extraConfig = {
    "51-alsa-rename" = {
      "monitor.alsa.rules" = [
        # Motherboard device
        {
          matches = [
            { "device.name" = "alsa_card.pci-0000_6f_00.6"; }
          ];
          actions = {
            update-props = {
              "device.nick" = "Motherboard Audio";
              "device.description" = "Motherboard Audio";
            };
          };
        }
        # Motherboard output sink
        {
          matches = [
            { "node.name" = "alsa_output.pci-0000_6f_00.6.analog-stereo"; }
          ];
          actions = {
            update-props = {
              "node.nick" = "Motherboard/Desk Speakers";
              "node.description" = "Motherboard/Desk Speakers";
            };
          };
        }
        # Motherboard input source
        {
          matches = [
            { "node.name" = "alsa_input.pci-0000_6f_00.6.analog-stereo"; }
          ];
          actions = {
            update-props = {
              "node.nick" = "Motherboard Mic";
              "node.description" = "Motherboard Mic";
            };
          };
        }
        # GPU device
        {
          matches = [
            { "device.name" = "alsa_card.pci-0000_6f_00.1"; }
          ];
          actions = {
            update-props = {
              "device.nick" = "GPU Audio";
              "device.description" = "GPU Audio";
            };
          };
        }
        # GPU output sink
        {
          matches = [
            { "node.name" = "alsa_output.pci-0000_6f_00.1.hdmi-stereo"; }
          ];
          actions = {
            update-props = {
              "node.nick" = "GPU/Monitor Speakers";
              "node.description" = "GPU/Monitor Speakers";
            };
          };
        }
      ];
    };
    #"log-level-debug" = {
    #  "context.properties" = {
    #    # Output Debug log messages as opposed to only the default level (Notice)
    #    "log.level" = "D";
    #  };
    #};
    #"wh-1000xm3-ldac-hq" = {
    #  "monitor.bluez.rules" = [
    #    {
    #      matches = [
    #        {
    #          # Match any bluetooth device with ids equal to that of a WH-1000XM3
    #          "device.name" = "~bluez_card.*";
    #          "device.product.id" = "0x0cd3";
    #          "device.vendor.id" = "usb:054c";
    #        }
    #      ];
    #      actions = {
    #        update-props = {
    #          # Set quality to high quality instead of the default of auto
    #          "bluez5.a2dp.ldac.quality" = "hq";
    #        };
    #      };
    #    }
    #  ];
    #};
  };
}
