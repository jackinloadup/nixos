{ pkgs
, ...
}: {
  imports = [
    #inputs.nixos-hardware.nixosModules.common-pc-laptop # currently being placesd per machine
  ];

  config = {
    hardware.brillo.enable = true; # userspace brightness control for users in video group

    home-manager.sharedModules = [
      {
        dconf.settings."org/gnome/desktop/interface".show-battery-percentage = true;
      }
    ];

    #services.upower.enable = true;
    #services.upower.criticalPowerAction = "Hibernate";

    services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    #services.logind.settings.Login.HandleLidSwitch = "hibernate";

    services.acpid = {
      handlers = {
        ac-power = {
          action = ''
            vals=($1)  # space separated string to array of multiple values
            case ''${vals[3]} in
                00000000)
                    echo unplugged >> /tmp/acpi.log
                    ${pkgs.brillo}/bin/brillo -e -S 50
                    ;;
                00000001)
                    echo plugged in >> /tmp/acpi.log
                    ${pkgs.brillo}/bin/brillo -e -S 100
                    ;;
                *)
                    echo unknown >> /tmp/acpi.log
                    ;;
            esac
          '';
          event = "ac_adapter/*";
        };
      };
    };

    ## Enable general power saving features.
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };

    #services.upower.enable = true;
    #services.upower.criticalPowerAction = "Hibernate";
  };
}
