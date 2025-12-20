{ self
, inputs
, pkgs
, lib
, ...
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
}
