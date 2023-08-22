{
  config,
  pkgs,
  nixosConfig,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  settings = import ../../settings;
  theme = settings.theme;
  fontsConfig = {
    names = [theme.font.mono.family];
    style = theme.font.mono.style;
    size = builtins.mul theme.font.size 1.0; # typecast to float
  };
in {
  imports = [
    ./base16.nix
  ];

  config = mkIf nixosConfig.services.xserver.windowManager.i3.enable {
    programs.alacritty.enable = true;

    xsession.windowManager.i3 = let
      left = "h"; # vim directions ftw
      down = "j";
      up = "k";
      right = "l";
      terminal = "alacritty";
      menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term=foot --dmenu='bemenu -i -l 10'";
    in {
      enable = true;
      config = {
        terminal = terminal;
        modifier = "Mod4";
        defaultWorkspace = "workspace number 1";
        assigns = {
          "10" = [{class = "^Spotify$";}];
        };
        menu = menu;

        #keybindings = lib.mkOptionDefault {
        keybindings = let
          mod = "Mod4";
        in {
          "${mod}+Return" = "exec ${terminal}";

          "${mod}+Shift+q" = "kill";
          "${mod}+space" = "exec ${menu}";

          "${mod}+${left}" = "focus left";
          "${mod}+${down}" = "focus down";
          "${mod}+${up}" = "focus up";
          "${mod}+${right}" = "focus right";

          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          "${mod}+Shift+${left}" = "move left";
          "${mod}+Shift+${down}" = "move down";
          "${mod}+Shift+${up}" = "move up";
          "${mod}+Shift+${right}" = "move right";

          "${mod}+Shift+Left" = "move workspace to output left";
          "${mod}+Shift+Up" = "move workspace to output up";
          "${mod}+Shift+Down" = "move workspace to output down";
          "${mod}+Shift+Right" = "move workspace to output right";

          "${mod}+Shift+space" = "floating toggle";
          #"${mod}+space" = "focus mode_toggle";

          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

          #"${mod}+p" =
          #  "exec ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g- screenshot-$(date +%Y%m%d-%H%M).png";

          "${mod}+g" = "split h";
          "${mod}+v" = "split v";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+comma" = "layout stacking";
          "${mod}+period" = "layout tabbed";
          "${mod}+slash" = "layout toggle split";
          "${mod}+a" = "focus parent";
          "${mod}+s" = "focus child";

          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+v" = ''mode "system:  [s]oft reboot [r]eboot  [p]oweroff  [l]ogout"'';

          "${mod}+r" = "mode resize";

          #"${mod}+L" = ''exec ${pkgs.swaylock}/bin/swaylock -i "$(${wallpaper}/bin/wallpaper get)"'';
          #"${mod}+Shift+Delete" = ''exec ${pkgs.swaylock}/bin/swaylock -i "~/background.jpg"'';
          #"${mod}+k" = "exec ${pkgs.mako}/bin/makoctl dismiss";
          #"${mod}+Shift+k" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";

          "${mod}+Shift+minus" = "move container to scratchpad";
          "${mod}+minus" = "scratchpad show";
        };
        colors = with config.lib.base16.theme; {
          background = "#${base00-hex}";
          #statusline = "#${base04-hex}";
          #separator = "#${base01-hex}";
          focused = {
            border = "#${base05-hex}";
            background = "#${base0D-hex}";
            text = "#${base00-hex}";
            indicator = "#${base0B-hex}";
            childBorder = "#${base0D-hex}";
          };
          focusedInactive = {
            border = "#${base03-hex}";
            background = "#${base01-hex}";
            text = "#${base05-hex}";
            indicator = "#${base03-hex}";
            childBorder = "#${base01-hex}";
          };
          unfocused = {
            border = "#${base03-hex}";
            background = "#${base01-hex}";
            text = "#${base05-hex}";
            indicator = "#${base0B-hex}";
            childBorder = "#${base01-hex}";
          };
          urgent = {
            border = "#${base08-hex}";
            background = "#${base08-hex}";
            text = "#${base00-hex}";
            indicator = "#${base08-hex}";
            childBorder = "#${base08-hex}";
          };
          placeholder = {
            border = "#${base00-hex}";
            background = "#${base0A-hex}";
            childBorder = "#${base0A-hex}";
            indicator = "#${base09-hex}";
            text = "#${base00-hex}";
          };
        };

        bars = with config.lib.base16.theme; [
          {
            #command = "${pkgs.waybar}/bin/waybar";
            #position = "top";
            #fonts = fontConf;
            #trayOutput = "*";
            colors = {
              background = "#${base00-hex}";
              statusline = "#${base04-hex}";
              separator = "#${base01-hex}";
              focusedWorkspace = {
                border = "#${base05-hex}";
                background = "#${base0D-hex}";
                text = "#${base00-hex}";
              };
              activeWorkspace = {
                border = "#${base05-hex}";
                background = "#${base03-hex}";
                text = "#${base00-hex}";
              };
              inactiveWorkspace = {
                border = "#${base03-hex}";
                background = "#${base01-hex}";
                text = "#${base05-hex}";
              };
              urgentWorkspace = {
                border = "#${base08-hex}";
                background = "#${base08-hex}";
                text = "#${base00-hex}";
              };
              bindingMode = {
                border = "#${base00-hex}";
                background = "#${base0A-hex}";
                text = "#${base00-hex}";
              };
            };
          }
        ];
      };
    };

    programs.i3status = with config.lib.base16.theme; {
      enable = true;

      general = {
        output_format = "i3bar";
        colors = true;
        color_good = "#${base08-hex}";
        color_degraded = "#${base05-hex}";
        color_bad = "#${base04-hex}";
      };

      modules = {
        "disk /dev/mapper/os-decrypted" = {
          position = 1;
          settings.format = "root: %percentage_used (%free free)";
          settings.low_threshold = "10";
        };
        "volume master" = {
          position = 3;
          settings.device = "pulse";
        };
        "wireless _first_" = {
          position = 4;
          enable = true;
        };
        #"ethernet _first_" = {
        #  position = 5;
        #  enable = hostName == "sirius";
        #};
        "battery all" = {
          position = 6;
          settings = {
            format = "%status %percentage %remaining %emptytime";
            format_down = "No battery";
            status_chr = "⚡ CHR";
            status_bat = "🔋 BAT";
            status_unk = "? UNK";
            status_full = "☻ FULL";
            path = "/sys/class/power_supply/BAT%d/uevent";
            low_threshold = 10;
            last_full_capacity = true;
            hide_seconds = true;
            integer_battery_capacity = true;
          };
          enable = true;
          #enable = hostName == "spica";
        };
        "tztime local" = {
          position = 7;
          settings.format = "%a %d %b %Y %H:%M";
        };
        ipv6.enable = false;
        load.enable = false;
        memory.enable = false;
      };
    };
  };
}
