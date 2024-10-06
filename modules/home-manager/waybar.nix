{
  nixosConfig,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (builtins) readFile;
  settings = import ../../settings;
  host = nixosConfig.networking.hostName;
  hasBattery =
    if host == "riko"
    then true
    else false;
in {
  imports = [
    ./base16.nix
  ];

  config = mkIf config.programs.waybar.enable {
    programs.waybar = {
      systemd = {
        enable = true;
        target = mkIf config.wayland.windowManager.sway.enable "sway-session.target"; # not available in HM 21.11
      };
      settings = [
        {
          height = 30;
          layer = "top";
          position = "bottom";
          #tray = { spacing = 10; };
          modules-center = [];
          #modules-center = ["sway/window"];
          modules-left = [
            "hyprland/workspaces"
            "sway/workspaces"
            "sway/mode"
          ];
          modules-right = [
            "custom/pkgwatt"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            (mkIf hasBattery "battery")
            "clock"
            "tray"
          ];
          "hyprland/workspaces" = {
            "format" = "{icon}";
            "on-scroll-up" = "hyprctl dispatch workspace e+1";
            "on-scroll-down" = "hyprctl dispatch workspace e-1";
            "on-click" = "activate";
          };
          "hyprland/window" = {
            "max-length" = 200;
            "separate-outputs" = true;
          };
          "custom/pkgwatt" = {
            format = "{}W";
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
              format-alt = "{ifname}: {ipaddr}/{cidr}";
              format-disconnected = "Disconnected ⚠";
              format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
              format-linked = "{ifname} (No IP) ";
              format-wifi = "{essid} ({signalStrength}%) ";
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
