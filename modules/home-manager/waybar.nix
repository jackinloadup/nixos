{
  nixosConfig,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
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
        #target = "sway-session.target"; # not available in HM 21.11
      };
      settings = [
        {
          height = 30;
          layer = "top";
          position = "bottom";
          #tray = { spacing = 10; };
          modules-center = [];
          #modules-center = ["sway/window"];
          modules-left = ["sway/workspaces" "sway/mode"];
          modules-right = [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            (mkIf hasBattery "battery")
            "clock"
            "tray"
          ];
          modules = {
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
          };
        }
      ];

      style = builtins.readFile ./waybar.css;
    };
  };
}
