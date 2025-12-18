{
  nixosConfig,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf getExe optionals;
  inherit (builtins) elem readFile;
  settings = import ../../settings;
  host = nixosConfig.networking.hostName;
  hostsWithBattery = [ "riko" "obsidian" ];
  hasBattery = elem host hostsWithBattery;
in {
  config = mkIf config.programs.waybar.enable {
    programs.waybar = {
      systemd = {
        enable = true;
        target = mkIf config.wayland.windowManager.hyprland.enable "hyprland-session.target";
        #target = []
          #++ optionals config.wayland.windowManager.sway.enable [ "sway-session.target" ]
        #++ optionals config.wayland.windowManager.hyprland.enable [ "hyprland-session.target" ]
        #++ optionals config.programs.niri.enable [ "niri.service" ];

      };
      settings = [
        {
          height = 30;
          layer = "top";
          position = "top";
          #tray = { spacing = 10; };
          modules-left = [
            "mpris"
            #"mpd"
          ];

          #modules-center = ["sway/window"];
          modules-center = [
            "hyprland/workspaces"
            "sway/workspaces"
            "niri/workspaces"
            "sway/mode"
          ];
          modules-right = [
            "custom/pkgwatt"
            #"pulseaudio"
            "wireplumber"
            "network"
            #"cpu"
            #"memory"
            #"temperature"
            "gamemode"
            (mkIf hasBattery "battery")
            "tray"
            "clock"
            "custom/quit"
          ];
          "hyprland/workspaces" = {
            "format" = "{icon}";
            "on-scroll-up" = "hyprctl dispatch workspace e+1";
            "on-scroll-down" = "hyprctl dispatch workspace e-1";
            "on-click" = "activate";
          };
          "niri/workspaces" = {
            all-outputs = false;
            current-only = false;
            format = "{index}";
            disable-click = true;
            disable-markup = true;
          };
          "hyprland/window" = {
            "max-length" = 200;
            "separate-outputs" = true;
          };
          "group/power" = {
            "orientation" = "vertical";
            "drawer" = {
                "transition-duration" = 500;
                "children-class" = "not-power";
                "transition-left-to-right" = true;
            };
            "modules" = [
                "custom/power" # // First element is the "group leader" and won't ever be hidden
                "custom/quit"
                "custom/lock"
                "custom/reboot"
            ];
           };
          "custom/pkgwatt" = {
            format = "{}W ";
            max-length = 8;
            interval = 15;
            exec = pkgs.writeShellScript "pkgs-watts" ''
              CPU=$(sudo ${getExe nixosConfig.boot.kernelPackages.turbostat} --Summary --quiet --show PkgWatt --num_iterations 1 | sed -n 2p)
              OTHER=$(${getExe pkgs.lm_sensors} | grep W | awk '{print $2}' | paste -sd+ | bc)
              ALL=$(echo "$CPU+$OTHER" | bc)
              printf "$ALL\n"
              exit 0
            '';
          };
           "custom/quit" = {
               "format" = "󰗼 ";
               "tooltip" = false;
               "on-click" = "hyprctl dispatch exit || niri msg action quit";
           };
           "custom/lock" = {
               "format" = "󰍁 ";
               "tooltip" = false;
               "on-click" = "hyprlock";
           };
           "custom/reboot" = {
               "format" = "󰜉 ";
               "tooltip" = false;
               "on-click" = "reboot";
           };
           "custom/power" = {
               "format" = "   ";
               "tooltip" = false;
               "on-click" = "poweroff";
           };
          #modules = {
            battery = mkIf hasBattery {
              format = "{capacity}% {icon}";
              format-alt = "{time} {icon}";
              format-charging = "{capacity}% ";
              format-icons = ["" "" "" "" ""];
              format-plugged = "{capacity}% ";
              states = {
                critical = 15;
                warning = 30;
              };
            };
            clock = {
              timezone = settings.home.timezone;
              tooltip-format = "{:%Y-%m-%d | %H:%M}";
              format-alt = "{:%H:%M}";
              format = "{:%OI:%OM %p %m-%d}";
            };
            cpu = {
              format = "{usage}% ";
              tooltip = false;
            };
            memory = {format = "{}% ";};
            network = {
              interval = 1;
              format = "{ifname}";
              format-alt = "{ifname}: {ipaddr}/{cidr}";
              format-disconnected = "";
              format-ethernet = "";
              #format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
              format-linked = "{ifname} (No IP) 󰌙";
              format-wifi = "{essid} ";
              tooltip-format = "{ifname} via {gwaddr} 󰊗";
              tooltip-format-wifi = " ({signalStrength}%) {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
              tooltip-format-ethernet = "{ipaddr}/{cidr} 󰊗  up: {bandwidthUpBits} down: {bandwidthDownBits}";
              tooltip-format-disconnected = "Disconnected 󰌙";
            };
            pulseaudio = {
              format = "{volume}% {icon} {format_source}";
              format-bluetooth = "{volume}% {icon} {format_source}";
              format-bluetooth-muted = " {icon} {format_source}";
              format-icons = {
                car = "";
                default = ["" "" ""];
                handsfree = "";
                headphones = "";
                headset = "";
                phone = "";
                portable = "";
              };
              format-muted = " {format_source}";
              format-source = "{volume}% ";
              format-source-muted = "";
              on-click = "pavucontrol";
            };
            "sway/mode" = {format = ''<span style="italic">{}</span>'';};
            temperature = {
              critical-threshold = 80;
              format = "{temperatureC}°C {icon}";
              format-icons = ["" "" ""];
            };
          #};
        }
      ];

      style = builtins.readFile ./waybar.css;
    };
  };
}
