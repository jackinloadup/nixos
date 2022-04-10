{ config, pkgs, nixosConfig, lib, inputs, ... }:
let
  settings = import ../settings;
  hostName = nixosConfig.networking.hostName;
  theme = settings.theme;
  #wallpaper = pkgs.callPackage ./wallpaper/wallpaper.nix { };
  fontConf = {
    names = [ theme.font.mono.family ];
    size = builtins.mul theme.font.size 1.0; # typecast to float
  };
  sway_tty1 = ''
      # if tty1 then dont fork, instead transfer execution to sway
      # thus if sway crashes the resulting terminal will not be logged in
      #[[ "$(tty)" == /dev/tty1 ]] && exec sway
    '';
in
{
  imports = [
    ./waybar.nix
    inputs.base16.hmModule
  ];

  #programs.bash.initExtra = if (nixosConfig.machine.sizeTarget > 1 ) then sway_tty1 else "";
  #programs.zsh.loginExtra  = if (nixosConfig.machine.sizeTarget > 1 ) then sway_tty1 else "";

  home.packages = with pkgs; lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) [
    #sway-contrib.grimshot
    wl-clipboard
    #mako
    #dmenu
    gnome.adwaita-icon-theme

    gksu # gui for root privilages # needed for zenmap
    # enable  xhost si:localuser:root
    # disable xhost -si:localuser:root
    xorg.xhost # needed to allow root apps to use gui $ xhost si:localuser:root
  ];

  services.flameshot.enable = true;

  wayland.windowManager.sway = lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) {
    enable = true;
    package = null; # don't override system-installed one
    wrapperFeatures.gtk = true;

    config = {
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      modifier = "Mod4";

      fonts = fontConf;

      terminal = "${pkgs.foot}/bin/footclient";

      workspaceAutoBackAndForth = true;
      window = {
        titlebar = true;
        hideEdgeBorders = "smart";
      };

      bars = with config.lib.base16.theme; [{
        command = "${pkgs.waybar}/bin/waybar";
        position = "top";
        #fonts = fontConf;
        trayOutput = "*";
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
      }];

      colors = with config.lib.base16.theme; {
        background = "#${base00-hex}";
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
      };

      floating.criteria = [{ class = "^Wine$"; }];

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

      menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term=foot --dmenu='bemenu -i -l 10'" ;

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
          "${mod}+Shift+v" = ''mode "system:  [s]oft reboot [r]eboot  [p]oweroff  [l]ogout"'';

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
          #"${mod}+z" = "exec ${pkgs.zathura}/bin/zathura";

          "${mod}+Shift+minus" = "move container to scratchpad";
          "${mod}+minus" = "scratchpad show";
        } // (if hostName == "spica" then { # smart. use hostname then append based on that
          "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
          "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
        } else { });

        modes =
        let
          terminal = config.wayland.windowManager.sway.config.terminal;
        in {
        "system:  [s]oft reboot [r]eboot  [p]oweroff  [l]ogout" = {
          s = "exec ${terminal} -e ./kexec-systemd.sh";
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
          h = "resize shrink width 10 px or 10 ppt";
          j = "resize grow height 10 px or 10 ppt";
          k = "resize shrink height 10 px or 10 ppt";
          l = "resize grow width 10 px or 10 ppt";
          Return = "mode default";
          Escape = "mode default";
        };
      };

      window.commands = [
        {
          command = "inhibit_idle fullscreen";
          criteria.class = "firefox";
        }
        {
          command = "inhibit_idle fullscreen";
          criteria.app_id = "mpv";
        }
        {
          command = "inhibit_idle fullscreen";
          criteria.class = "LBRY";
        }
        {
          command = "inhibit_idle fullscreen";
          criteria.class = "Kodi";
        }
        {
          # spotify doesn't set its WM_CLASS until it has mapped, so the assign is not reliable
          command = "move --no-auto-back-and-forth window to workspace 10";
          criteria.class = "Spotify";
        }
        #{
        #  command = "opacity ${builtins.toString theme.background_opacity}";
        #  criteria.app_id = "firefox";
        #}
        #{
        #  command = "move to scratchpad";
        #  criteria = {
        #    app_id = "org.keepassxc.KeePassXC";
        #    title = "^Passwords.kdbx";
        #  };
        #}
      ];

      output = {
        "*".bg = ''~/Pictures/background.jpg fill'';
      };
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
        # following needed to launch root apps
        # can be disabled with `xhost -si:localhost:root`
        # ideally we would enable and disable as needed
        # This doesn't work here so I'm just leaving it atm
        # until I care to figure out how to declare this
        # in a way I like
        #{ command = "${pkgs.xorg.xhost}/bin/xhost si:localhost:root"; }

        { command = "${pkgs.foot}/bin/foot --server"; }
        #{ command = "${pkgs.mako}/bin/mako"; }
        #{ command = "${pkgs.nextcloud-client}/bin/nextcloud"; }
        #{ command = "${pkgs.keepassxc}/bin/keepassxc"; }
        {
          command =
            #let lockCmd = "'${pkgs.swaylock}/bin/swaylock -f -i \"\$(${wallpaper}/bin/wallpaper get)\"'";
            let
              lockCmd = "'${pkgs.swaylock}/bin/swaylock -f -i \"~/Pictures/background.jpg\"'";
              timeouts = settings.timeouts;
            in
            ''${pkgs.swayidle}/bin/swayidle -w \
              timeout ${toString timeouts.screenLock} ${lockCmd} \
              timeout ${toString timeouts.displayOff} 'swaymsg "output * dpms off"' \
              resume 'swaymsg "output * dpms on"' \
              before-sleep ${lockCmd}
           '';
        }
        #{ command = "${config.programs.firefox.package}/bin/firefox"; }
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
      seat seat0 xcursor_theme ${theme.cursor.name} ${toString theme.cursor.size}
      default_border pixel 2
      workspace 1
    '';
  };
}
