{
  self,
  inputs,
  pkgs,
  lib,
  ...
}: {
  environment.etc."wireplumber/main.lua.d/51-device-rename.lua" = {
    text = ''
      motherboard = {
        matches = {
          {
            { "device.vendor.id", "equals", "4130" },
          },
        },
        apply_properties = {
          ["device.description"] = "Motherboard",
          ["device.nick"] = "Motherboard",
        },
      }

      table.insert(alsa_monitor.rules, motherboard)

      gpu = {
        matches = {
          {
            { "device.vendor.id", "equals", "4098" },
          },
        },
        apply_properties = {
          ["device.description"] = "GPU",
          ["device.nick"] = "GPU",
        },
      }

      table.insert(alsa_monitor.rules, gpu)
    '';
  };

  # media-session gone in NIXOS 23.05
  #services.pipewire = {
  #  media-session.config.alsa-monitor.rules = [
  #    {
  #      matches = [{"device.vendor.id" = "4130";}];
  #      actions = {
  #        "update-props" = {
  #          "device.description" = "Motherboard";
  #          "device.product.name" = "Motherboard";
  #        };
  #      };
  #    }
  #    {
  #      matches = [{"device.vendor.id" = "4098";}];
  #      actions = {
  #        "update-props" = {
  #          "device.description" = "GPU";
  #          "device.product.name" = "GPU";
  #        };
  #      };
  #    }
  #  ];
  #};
  services.pipewire.wireplumber.extraConfig = {
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
