{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault getBin getExe optionals;
  termCmd = "${getBin pkgs.foot}/bin/footclient --client-environment";
  #termCmd = "${getExe pkgs.kitty}";
  left = "h";
  down = "j";
  up = "k";
  right = "l";
in {
  config = let
    menu = "${getExe pkgs.j4-dmenu-desktop} --no-generic --term='${termCmd}' --dmenu='${getExe pkgs.bemenu} --ignorecase --list 10 --center --border-radius 12 --width-factor \"0.2\" --border 2 --margin 20 --fixed-height --prompt \"\" --prefix \">\" --line-height 20 --ch 15'";
  in {
    home.packages = [
      pkgs.hyprlock
    ];

    programs.foot.enable = true;
    programs.foot.server.enable = true;

    # currently controlled per host :-(
    programs.wpaperd = {
      #enable = mkDefault true;
      settings = {
        default  = {
          #path = "${config.xdg.cacheHome}/satellite-images";
          #path = "$XDG_CACHE_HOME/satellite-images";
          # commenting out due to single image vs dir

          #path = "~/Pictures/Wallpapers";
          #sorting = "random";
          #duration = "5m";
          #apply-shadow = false
        };

      };
    };
    programs.waybar.enable = true;

    # Clamshell mode references available in MatthiasBenaets/modules/desktops/hyprland.nix
#    home.file = {
#      ".config/hypr/script/clamshell.sh" = let
#        lid = "LID";
#        mainMonitor = "eDP-1";
#      in {
#        text = ''
#          #!/bin/sh
#
#          if grep open /proc/acpi/button/lid/${lid}/state; then
#            ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, 1920x1080, 0x0, 1"
#          else
#            if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
#              ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, disable"
#            else
#              ${pkgs.hyprlock}/bin/hyprlock
#              ${pkgs.systemd}/bin/systemctl suspend
#            fi
#          fi
#        '';
#        executable = true;
#      };
#    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
           after_sleep_cmd = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
           ignore_dbus_inhibit = false;
           lock_cmd = "hyprlock";
         };

         listener = [
           {
             timeout = 900;
             on-timeout = "hyprlock";

             #lockCmd = "pidof ${hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock || ${hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock";
           }
           {
             timeout = 960;
             on-timeout = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";
             on-resume = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
           }
         ];
      };
    };

    #security.pam.services.hyprlock = {
    #  text = "auth include system-auth";
    #  fprintAuth = false;
    #};

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          no_fade_in = false;
          disable_loading_bar = true;
          grace = 5;
        };
        background = [{
        #  monitor = "";
          path = "/home/lriutzel/Pictures/background.jpg";
        #  color = "rgba(25, 20, 20, 1.0)";
        #  blur_passes = 1;
        #  blur_size = 0;
        #  brightness = 0.2;
        }];
        input-field = [
          { # Password Field
            monitor = "";
            size = "200,60";
            outline_thickness = 2;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(0, 0, 0, 0.5)";
            font_color = "rgb(200, 200, 200)";
            fade_on_empty = true;
            placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
            hide_input = false;
            position = "0,-120";
            halign = "center";
            valign = "center";
          }
        ];
        label = [
          { # Time
            monitor = "";
            text = ''cmd[update:1000] echo "<span>$(date +"%I:%M")</span>"'';
            color = "rgba(216, 222, 233, .85)";
            #text = "$TIME12";
            font_size = 120;
            position = "0, -240";
            valign = "center";
            halign = "center";
          }
          { # Day-Month-Date
            monitor = "";
            text = ''cmd[update:1000] echo -e "$(date +"%A, %B %d")"'';
            color = "rgba(216, 222, 233, .85)";
            font_size = 32;
            #font_family = "SF Pro Display Bold";
            position = "0, -100";
            halign = "center";
            valign = "center";
          }
        ];

        #shape = { # Blurred box
        #  monitor = "";
        #  size = "320, 480";
        #  color = "rgba(255, 255, 255, 0.3)";
        #  rounding = 30;
        #  border_size = 0;
        #  border_color = "rgba(255, 255, 255, 1)";
        #  rotate = 0;
        #  xray = false; # if true, make a "hole" in the background (rectangle of specified size, no rotation)
        #  position = "-60, -90";
        #  halign = "center";
        #  valign = "center";
        #};
      };
    };


    wayland.windowManager.hyprland = {
      plugins = [ pkgs.hyprlandPlugins.hy3 ];

      extraConfig = ''
        monitor = , preferred, auto, 1

        bind=$mod,escape,submap,(p)oweroff, (s)uspend, (h)ibernate, (r)eboot, (l)ogout
        submap=(p)oweroff, (s)uspend, (h)ibernate, (r)eboot, (l)ogout

        bind=,p,exec,systemctl poweroff
        bind=,p,submap,reset

        bind=,s,exec,systemctl suspend-then-hibernate
        bind=,s,submap,reset

        bind=,h,exec,systemctl hibernate
        bind=,h,submap,reset

        bind=,r,exec,systemctl reboot
        bind=,r,submap,reset

        bind=,l,exit
        bind=,l,submap,reset

        bind=,escape,submap,reset
        bind=,return,submap,reset
        submap=reset
      '';

      settings = {

        animations = {
          enabled = true;
          # Selmer443 config
          bezier = [
            "pace,0.46, 1, 0.29, 0.99"
            "overshot,0.13,0.99,0.29,1.1"
            "md3_decel, 0.05, 0.7, 0.1, 1"

            "wind, 0.05, 0.9, 0.1, 1.05"
            "winIn, 0.1, 1.1, 0.1, 1.1"
            "winOut, 0.3, -0.3, 0, 1"
            "liner, 1, 1, 1, 1"

            "easeOutQuart, 0.25, 1, 0.5, 1"
          ];
          animation = [
            "border, 1, 1, liner"
            "borderangle, 1, 30, liner, loop"
            "fade, 1, 3, default"
            "windows, 1, 3, wind, slide"
            "windowsIn, 1, 3, easeOutQuart, popin"
            "windowsOut, 1, 3, winOut, slide"
            "windowsMove, 1, 3, wind, slide"
            "workspaces, 1, 3, md3_decel"

            #"border,1,10,md3_decel"
            #"fade,1,10,md3_decel"

            #"windowsIn,1,6,md3_decel,slide"
            #"windowsOut,1,6,md3_decel,slide"
            #"windowsMove,1,6,md3_decel,slide"

            #"workspaces,1,9,md3_decel,slide"
            #"workspaces, 1, 6, default"

            "specialWorkspace,1,8,md3_decel,slide"
          ];
        };

        #"$mod" = "SUPER";
        "$terminal" = "${termCmd}";
        bind = [
          "$mod, Return, exec, ${termCmd}"
          "$mod SHIFT, q, hy3:killactive"
          "$mod, Space, exec, ${menu}"
          "$mod SHIFT, Space, togglefloating"
          "$mod, f, fullscreen"

          # idk why this isn't working
          #"$mod SHIFT, code:61, togglesplit,"
          #"$mod SHIFT, I, togglegroup"
          #"$mod, /, togglesplit,"
          #"$mod,code:61,togglesplit,"
          #"$mod,x,togglesplit,"

          # Horizontal Stack Group
          "$mod, g, hy3:makegroup, h, ephemeral"
          # Vertical Stack Group
          "$mod, v, hy3:makegroup, v, ephemeral"
          # Change Group Type (vertical/horizontal)
          "$mod, /, hy3:changegroup, opposite"
          # Horizontal Tabs
          "$mod, z, hy3:changegroup, toggletab, ephemeral"
          "$mod, a, hy3:changefocus, raise"
          "$mod, s, hy3:changefocus, lower"
          "$mod, e, hy3:expand, expand"
          "$mod+SHIFT, e, hy3:expand, shrink"

          ## move focus with arrows
          #"$mod, left, movefocus, l"
          #"$mod, right, movefocus, r"
          #"$mod, up, movefocus, u"
          #"$mod, down, movefocus, d"

          ## move focus with vim keys
          #"$mod, ${left}, movefocus, l"
          #"$mod, ${right}, movefocus, r"
          #"$mod, ${up}, movefocus, u"
          #"$mod, ${down}, movefocus, d"

          ## move window with vim keys
          #"$mod SHIFT, ${left}, movewindow, l"
          #"$mod SHIFT, ${right}, movewindow, r"
          #"$mod SHIFT, ${up}, movewindow, u"
          #"$mod SHIFT, ${down}, movewindow, d"

          ##switch workspaces with mod + [0-9]
          #"$mod, 1, workspace, 1"
          #"$mod, 2, workspace, 2"
          #"$mod, 3, workspace, 3"
          #"$mod, 4, workspace, 4"
          #"$mod, 5, workspace, 5"
          #"$mod, 6, workspace, 6"
          #"$mod, 7, workspace, 7"
          #"$mod, 8, workspace, 8"
          #"$mod, 9, workspace, 9"
          #"$mod, 0, workspace, 10"
          ## Move active window to a workspace with mod + SHIFT + [0-9]
          #"$mod SHIFT, 1, movetoworkspace, 1"
          #"$mod SHIFT, 2, movetoworkspace, 2"
          #"$mod SHIFT, 3, movetoworkspace, 3"
          #"$mod SHIFT, 4, movetoworkspace, 4"
          #"$mod SHIFT, 5, movetoworkspace, 5"
          #"$mod SHIFT, 6, movetoworkspace, 6"
          #"$mod SHIFT, 7, movetoworkspace, 7"
          #"$mod SHIFT, 8, movetoworkspace, 8"
          #"$mod SHIFT, 9, movetoworkspace, 9"
          #"$mod SHIFT, 0, movetoworkspace, 10"

        ];

        bindm = [ # Mouse binds
          # "SUPER,mouse_down,workspace,e+1"
          # "SUPER,mouse_up,workspace,e-1"
          "SUPER,mouse:272,movewindow"
          "SUPER,mouse:273,resizewindow"
        ];

        binds = {
          workspace_back_and_forth = true;
          allow_workspace_cycles = true;
        };

        windowrulev2 = [
          "float,title:^(Volume Control)$"
          "keepaspectratio,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "noborder,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "float, title:^(Picture-in-Picture)$"
          "size 24% 24%, title:(Picture-in-Picture)"
          "move 75% 75%, title:(Picture-in-Picture)"
          "pin, title:^(Picture-in-Picture)$"
          "float, title:^(Firefox)$"
          "size 24% 24%, title:(Firefox)"
          "move 74% 74%, title:(Firefox)"
          "pin, title:^(Firefox)$"
          "opacity 0.9, class:^(kitty)"
          "tile,initialTitle:^WPS.*"
        ];

        gestures = {
          workspace_swipe = true;
        };

        general = {
          layout = "hy3";
          border_size = 1;
          gaps_in = 16;
          gaps_out = 32;
          resize_on_border = true;
          "col.active_border" = "0x99f000aa";
          "col.inactive_border" = "0x66000000";
        };

        decoration = {
          rounding = 16;
          blur = {
            enabled = true;
            size = 3;
            passes = 2;
            xray = true;
            ignore_opacity = true;
            new_optimizations = true;
            noise = 0.02;
            contrast = 1.05;
            brightness = 1.2;
          };
          #drop_shadow = true;
          #shadow_range = 5;
          #shadow_render_power = 2;
          #shadow_offset = "3 3";
          #"col.shadow" = "0x99000000";
          #"col.shadow_inactive" = "0x55000000";
          active_opacity = 1;
          inactive_opacity = 1;
          fullscreen_opacity = 1.0;
        };

        input = {
          kb_layout = "us";
          #kb_variant = "";
          #kb_model = "pc105";
          #kb_options = "ctrl:nocaps,grp:switch,compose:rctrl";
          #kb_rules = "";

          follow_mouse = 1;

          touchpad = {
            natural_scroll = false;
            disable_while_typing = true;
            tap-to-click = true;
          };
        };

        exec-once = [
          #"${pkgs.mpvpaper}/bin/mpvpaper  --auto-stop --auto-pause --mpv-options \"no-audio loop\" DP-5 ~/.cache/satellite-images/goes-east/output.mp4"
          "${pkgs.wpaperd}/bin/wpaperd --daemon"
          #"${swayidleCommand}/bin/swayidle"
        ];

        group = {
          groupbar = {
            font_size = 12;
            gradients = false;
            "col.inactive" = "0x2E344000";
            "col.active" = "0x5E81AC00";
          };
        };

#        master = {
#          no_gaps_when_only = true;
#        };

        misc.disable_hyprland_logo = true;
        misc.disable_splash_rendering = true;
        plugin = {
          hy3 = {
            # disable gaps when only one window is onscreen
            # 0 - always show gaps
            # 1 - hide gaps with a single window onscreen
            # 2 - 1 but also show the window border
            no_gaps_when_only = 1; # default: 0

            # policy controlling what happens when a node is removed from a group,
            # leaving only a group
            # 0 = remove the nested group
            # 1 = keep the nested group
            # 2 = keep the nested group only if its parent is a tab group
            node_collapse_policy = 2; # default: 2

            # offset from group split direction when only one window is in a group
            group_inset = 10; # default: 10

            # if a tab group will automatically be created for the first window spawned in a workspace
            tab_first_window = false;

            # tab group settings
            tabs = {
              # height of the tab bar
              height = 15; # default: 15

              # padding between the tab bar and its focused node
              padding = 5; # default: 5

              # the tab bar should animate in/out from the top instead of below the window
              from_top = false; # default: false

              # rounding of tab bar corners
              rounding = 5; # default: 3

              # render the window title on the bar
              render_text = true; # default: true

              # center the window title
              text_center = false; # default: false

              # font to render the window title with
              text_font = "Sans"; # default: Sans

              # height of the window title
              text_height = 8; # default: 8

              # left padding of the window title
              text_padding = 3; # default: 3

              # active tab bar segment color
              #col.active = <color> # default: 0xff32b4ff

              # urgent tab bar segment color
              #col.urgent = <color> # default: 0xffff4f4f

              # inactive tab bar segment color
              #col.inactive = <color> # default: 0x80808080

              # active tab bar text color
              #col.text.active = <color> # default: 0xff000000

              # urgent tab bar text color
              #col.text.urgent = <color> # default: 0xff000000

              # inactive tab bar text color
              #col.text.inactive = <color> # default: 0xff000000
            };

            # autotiling settings
            autotile = {
              # enable autotile
              enable = false; # default: false

              # make autotile-created groups ephemeral
              ephemeral_groups = true; # default: true

              # if a window would be squished smaller than this width, a vertical split will be created
              # -1 = never automatically split vertically
              # 0 = always automatically split vertically
              # <number> = pixel height to split at
              trigger_width = 800; # default: 0

              # if a window would be squished smaller than this height, a horizontal split will be created
              # -1 = never automatically split horizontally
              # 0 = always automatically split horizontally
              # <number> = pixel height to split at
              trigger_height = 500; # default: 0

              # a space or comma separated list of workspace ids where autotile should be enabled
              # it's possible to create an exception rule by prefixing the definition with "not:"
              # workspaces = 1,2 # autotiling will only be enabled on workspaces 1 and 2
              # workspaces = not:1,2 # autotiling will be enabled on all workspaces except 1 and 2
              #workspaces = <string> # default: all
            };
          };
        };
      };
    };
  };
}
