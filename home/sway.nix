{ config, pkgs, nixosConfig, lib, ... }:
let
  settings = import ../settings;
  colorscheme = settings.colorscheme;
  hostName = nixosConfig.networking.hostName;
  theme = "Adwaita";
  #wallpaper = pkgs.callPackage ./wallpaper/wallpaper.nix { };
  fontConf = {
    names = [ "FuraCode Nerd Font" ];
    size = 12.0;
  };
in
{
  imports = [
    ../common/waybar
  ];

  home.packages = with pkgs; [
    #sway-contrib.grimshot
    alacritty
    sway
    swaylock
    swayidle
    wev
    wl-clipboard
    waybar
    #mako
    #dmenu
    firefox
    gnome.adwaita-icon-theme
    bemenu
    j4-dmenu-desktop
    thunderbird
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null; # don't override system-installed one

    config = {
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      modifier = "Mod4";

      fonts = fontConf;

      terminal = "${pkgs.alacritty}/bin/alacritty";

      #workspaceAutoBackAndForth = true;
      window = {
        titlebar = true;
        hideEdgeBorders = "smart";
      };

      bars = [{
        #statusCommand = "${pkgs.i3status}/bin/i3status";
        command = "${pkgs.waybar}/bin/waybar";
        position = "top";
        #fonts = fontConf;
        trayOutput = "*";
        colors = {
          background = "#${colorscheme.bg_0}";
          statusline = "#${colorscheme.fg_0}";
          separator = "#${colorscheme.fg_0}";
          focusedWorkspace = {
            border = "#${colorscheme.bg_1}";
            background = "#${colorscheme.bg_2}";
            text = "#${colorscheme.fg_1}";
          };
          activeWorkspace = {
            border = "#${colorscheme.bg_0}";
            background = "#${colorscheme.bg_1}";
            text = "#${colorscheme.fg_1}";
          };
          inactiveWorkspace = {
            border = "#${colorscheme.bg_0}";
            background = "#${colorscheme.bg_0}";
            text = "#${colorscheme.dim_0}";
          };
          urgentWorkspace = {
            border = "#${colorscheme.bg_1}";
            background = "#${colorscheme.red}";
            text = "#${colorscheme.fg_1}";
          };
        };
      }];

      colors = {
        focused = {
          border = "#${colorscheme.blue}";
          background = "#${colorscheme.blue}";
          text = "#${colorscheme.fg_1}";
          indicator = "#${colorscheme.blue}";
          childBorder = "#${colorscheme.blue}";
        };
        focusedInactive = {
          border = "#${colorscheme.bg_1}";
          background = "#${colorscheme.bg_1}";
          text = "#${colorscheme.fg_0}";
          indicator = "#${colorscheme.bg_1}";
          childBorder = "#${colorscheme.bg_1}";
        };
        unfocused = {
          border = "#${colorscheme.bg_0}";
          background = "#${colorscheme.bg_0}";
          text = "#${colorscheme.dim_0}";
          indicator = "#${colorscheme.bg_0}";
          childBorder = "#${colorscheme.bg_0}";
        };
        urgent = {
          border = "#${colorscheme.red}";
          background = "#${colorscheme.red}";
          text = "#${colorscheme.fg_1}";
          indicator = "#${colorscheme.red}";
          childBorder = "#${colorscheme.red}";
        };
      };

      floating.criteria = [{ class = "^Steam$"; } { class = "^Wine$"; }];

      #input = {
      #  "type:keyboard" =
      #    if hostName == "spica" then {
      #      xkb_layout = "print-switch";
      #    } else {
      #      xkb_layout = "gb,apl,gr";
      #      xkb_variant = "colemak,,";
      #      xkb_options = "grp:ctrls_toggle,grp:menu_switch";
      #      xkb_numlock = "enabled";
      #    };
      #  "type:touchpad" = {
      #    click_method = "clickfinger";
      #    tap = "enabled";
      #  };
      #};

      #menu = "${pkgs.bemenu}/bin/bemenu-run -m all --fn 'Concourse T7' --tf '#${colorscheme.dark.bg_0}' --hf '#${colorscheme.dark.fg_0}' --no-exec | xargs swaymsg exec --";
      #menu = "${pkgs.bemenu}/bin/bemenu-run -m all -l 10 --tf '#${colorscheme.dark.bg_0}' --hf '#${colorscheme.dark.fg_0}' --no-exec | xargs swaymsg exec --";
      menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term=alacritty --dmenu='bemenu -i -l 10'" ;

      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
          inherit (config.wayland.windowManager.sway.config)
            left down up right menu terminal;
        in
        {
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

          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

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

          "${mod}+p" =
            "exec ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g- screenshot-$(date +%Y%m%d-%H%M).png";

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
          "${mod}+Shift+v" = ''mode "system:  [r]eboot  [p]oweroff  [l]ogout"'';

          "${mod}+r" = "mode resize";

          #"${mod}+L" = ''exec ${pkgs.swaylock}/bin/swaylock -i "$(${wallpaper}/bin/wallpaper get)"'';
          "${mod}+Shift+Delete" = ''exec ${pkgs.swaylock}/bin/swaylock -i "~/background.jpg"'';
          #"${mod}+k" = "exec ${pkgs.mako}/bin/makoctl dismiss";
          #"${mod}+Shift+k" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";

          #"XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          #"XF86AudioRaiseVolume" =
          #  "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          #"XF86AudioLowerVolume" =
          #  "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";

          "${mod}+apostrophe" = "move workspace to output right";

          #"${mod}+z" = "exec ${pkgs.zathura}/bin/zathura";

          "${mod}+minus" = "scratchpad show";
          "${mod}+underscore" = "move container to scratchpad";
        } // (if hostName == "spica" then {
          "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
          "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
        } else { });

      modes = {
        "system:  [r]eboot  [p]oweroff  [l]ogout" = {
          r = "exec reboot";
          p = "exec poweroff";
          l = "exit";
          Return = "mode default";
          Escape = "mode default";
        };
        resize = {
          Left = "resize shrink width 10 px or 10 ppt";
          Down = "resize grow height 10 px or 10 ppt";
          Up = "resize shrink height 10 px or 10 ppt";
          Right = "resize grow width 10 px or 10 ppt";
          Return = "mode default";
          Escape = "mode default";
        };
      };

      window.commands = [
        {
          command = "inhibit_idle fullscreen";
          criteria.app_id = "firefox";
        }
        {
          command = "inhibit_idle fullscreen";
          criteria.app_id = "mpv";
        }
        {
          command = "inhibit_idle fullscreen";
          criteria.class = "Kodi";
        }
        {
          # spotify doesn't set its WM_CLASS until it has mapped, so the assign is not reliable
          command = "move to workspace 10";
          criteria.class = "Spotify";
        }
        #{
        #  command = "move to scratchpad";
        #  criteria = {
        #    app_id = "org.keepassxc.KeePassXC";
        #    title = "^Passwords.kdbx";
        #  };
        #}
      ];

      output = { "*".bg = ''~/background.jpg fit''; };
      #  (if hostName == "sirius" then {
      #    "Unknown LCD QHD 1 110503_3" = {
      #      pos = "1920 0";
      #      mode = "2560x1440";
      #    };
      #    "Goldstar Company Ltd W2363D 0000000000".pos = "0 0";
      #  } else if hostName == "aldebaran" then {
      #    Virtual-1.mode = "--custom 1920x1080";
      #  } else
      #    { });

      startup = [
        #{ command = "${pkgs.mako}/bin/mako"; }
        #{ command = "${pkgs.nextcloud-client}/bin/nextcloud"; }
        #{ command = "${pkgs.keepassxc}/bin/keepassxc"; }
        {
          command =
            #let lockCmd = "'${pkgs.swaylock}/bin/swaylock -f -i \"\$(${wallpaper}/bin/wallpaper get)\"'";
            let lockCmd = "'${pkgs.swaylock}/bin/swaylock -f -i \"~/background.jpg\"'";
            in
            ''${pkgs.swayidle}/bin/swayidle -w \
            timeout 600 ${lockCmd} \
            timeout 1200 'swaymsg "output * dpms off"' \
            resume 'swaymsg "output * dpms on"' \
            before-sleep ${lockCmd}
      '';
        }
        { command = "${config.programs.firefox.package}/bin/firefox"; }
        #{ command = "${pkgs.foot}/bin/foot --title weechat --app-id weechat weechat"; }
        #{ command = "${pkgs.slack}/bin/slack"; }
        #{ command = "${pkgs.element-desktop-wayland}/bin/element-desktop"; }
        #{ command = "${pkgs.spotify}/bin/spotify"; }
      ];

      assigns = {
        "1" = [
          { app_id = "firefox"; }
        ];
        #"8" = [
        #  { app_id = "weechat"; }
        #  { class = "Slack"; }
        #  { app_id = "Element"; }
        #];
      };

      #workspaceOutputAssign = lib.mkIf (hostName == "sirius") [
      #  { workspace = "1"; output = "Unknown LCD QHD 1 110503_3"; }
      #  { workspace = "2"; output = "Unknown LCD QHD 1 110503_3"; }
      #  { workspace = "8"; output = "Goldstar Company Ltd W2363D 0000000000"; }
      #  { workspace = "10"; output = "Goldstar Company Ltd W2363D 0000000000"; }
      #];
    };

    extraConfig = ''
      seat seat0 xcursor_theme ${theme}\n
      default_border pixel 2\n
      workspace 1
    '';
  };
}
