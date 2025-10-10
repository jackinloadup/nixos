{
  config,
  pkgs,
  nixosConfig,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf getBin getExe optionals;
  inherit (builtins) elem mul;

  settings = import ../../../settings;
  hostName = nixosConfig.networking.hostName;
  theme = settings.theme;
  fontConf = {
    names = [theme.font.mono.family];
    size = mul theme.font.size 1.0; # typecast to float
  };
  swayConfig = config.wayland.windowManager.sway.config;
  footTERM =
    if config.programs.foot.settings ? main.term
    then config.programs.foot.settings.main.term
    else "foot";
  termCmd = "${getBin pkgs.foot}/bin/footclient --client-environment";
  mode_record = "Capture: [p]icture [f]ullscreen or [enter] to leave mode this mode";
  background = "${config.xdg.cacheHome}/satellite-images/goes-east/current.jpg";
  background_backup = "/run/current-system/sw/share/backgrounds/gnome/keys-d.webp";


  #${getExe pkgs.swaylock} -f -i /run/current-system/sw/share/backgrounds/gnome/keys-d.webp
  triggerLock = pkgs.writeShellApplication {
    name = "lock-wm";
    runtimeInputs = [ pkgs.procps ];
    text = ''pkill -SIGUSR1 swayidle'';
  };

  lockCmd = pkgs.writeShellApplication {
    name = "lock";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.sway
      pkgs.swaylock
      pkgs.fd
    ];
    text = ''
      main () {
        BG=
        if [ -L "${background}" ]; then
          LINK_PATH=$(readlink "${background}")
          if [ -e "$LINK_PATH" ]; then
            BG="${background}"
          else
            BG="${background_backup}"
          fi
        else
          BG="${background_backup}"
        fi

        hyprland "$BG" &
        sway "$BG" &
      }

      hyprland () {
        BG="$1"
        if hyprctl instances; then
          swaylock -f -i "$BG"
        fi
      }

      sway () {
        BG="$1"
        SWAYSOCK=$(fd sway-ipc /run/user/$UID/ -1)

        if [[ -n "$SWAYSOCK" ]]; then
          swaylock -f -i "$BG"
        fi
      }

      main "$@"
    '';
  };

  displayOnOffCmd =  pkgs.writeShellApplication {
    name = "displayOnOffCmd";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.sway
      pkgs.hyprland
      pkgs.fd
    ];

    # TODO on mobile devices we are missing images while sleeping
    text = ''
      set -o xtrace

      usage () {
          echo >&2 "Usage: $0 off/on"
      }

      main () {
        [[ "$1" = "on" ]] && STATE="ON"
        [[ "$1" = "off" ]] && STATE="OFF"

        if [ "$1" = "--help" ]; then
          usage
          exit 0
        fi

        hyprland &
        sway &

        wait
      }

      hyprland () {
        if hyprctl instances 1>/dev/null 2>/dev/null; then
          echo "Hyprland"
          if [[ "$STATE" = "ON" ]]; then
            hyprctl dispatch dpms on
            echo "request display on"
          else
            #sleep 5 # if SIGUSR1 triggers this and lock. wait for the lock first
            hyprctl dispatch dpms off
            echo "request display off"
            #sleep 5 # if SIGUSR1 triggers this and lock. wait for the lock first
            #hyprctl dispatch dpms off
            #echo "request display off"
          fi
        fi
      }

      sway () {
        SWAYSOCK=$(fd sway-ipc /run/user/$UID/ -1)

        if [[ -n "$SWAYSOCK" ]]; then
          echo "Sway"
          if [[ "$STATE" = "ON" ]]; then
            swaymsg "output * dpms on"
            echo "request display on"
          else
            sleep 5 # if SIGUSR1 triggers this and lock. wait for the lock first
            swaymsg "output * dpms off"
            echo "request display off"
            sleep 5 # if SIGUSR1 triggers this and lock. wait for the lock first
            swaymsg "output * dpms off"
            echo "request display off"
          fi
        fi
      }

      main "$@"
    '';
  };
in {
  imports = [
    ../waybar.nix
  ];

  config = mkIf config.wayland.windowManager.sway.enable {
    programs.foot.enable = true;
    programs.foot.server.enable = true;
    programs.waybar.enable = true;
    services.dunst.enable = true;

    # This makes login take 3 seconds
    programs.zsh.loginExtra = "export SWAYSOCK=$(${getExe pkgs.fd} sway-ipc /run/user/$UID/ -1)";
    programs.bash.initExtra = "export SWAYSOCK=$(${getExe pkgs.fd} sway-ipc /run/user/$UID/ -1)";

    home.packages = [
        #pkgs.sway-contrib.grimshot
        pkgs.wl-clipboard
        #pkgs.mako
        #pkgs.dmenu
        pkgs.ddcutil
        pkgs.gopsuinfo

        #gksu # gui for root privilages # needed for zenmap # gone in unstable
        triggerLock
      ]
      ++ optionals config.wayland.windowManager.sway.xwayland [
        # enable  xhost si:localuser:root
        # disable xhost -si:localuser:root
        pkgs.xorg.xhost # needed to allow root apps to use gui $ xhost si:localuser:root
      ];

    home.sessionVariables = {
      # Hint to electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };

    # disabling for now due to i3. This could be started in commands but maybe systemd mod better?
    #services.flameshot.enable = true;

    wayland.windowManager.sway = {
      package = null; # don't override system-installed one
      systemd.enable = true;
      wrapperFeatures.gtk = true;

      config = {
        left = "h";
        down = "j";
        up = "k";
        right = "l";

        modifier = "Mod4";

        fonts = fontConf;

        #terminal = "TERM=${footTERM} ${termCmd}";
        terminal = "TERM=kitty kitty";

        workspaceAutoBackAndForth = true;

        input = import ./input.nix;
        output = import ./output.nix;
        window = import ./window.nix;
        bars = [];

        floating.criteria = [{class = "^Wine$";}];

        #menu = "${getExe pkgs.j4-dmenu-desktop} --no-generic --term='${termCmd}' --dmenu='${getExe pkgs.bemenu} --ignorecase --list 10 --center --border-radius 12 --width-factor \"0.2\" --border 2 --margin 20 --fixed-height --prompt \"\" --prefix \">\" --line-height 20 --ch 15'";
        menu = "${getExe pkgs.j4-dmenu-desktop} --no-generic --term='${termCmd}' --dmenu='${getExe pkgs.bemenu} --ignorecase --list 10 --center --border-radius 12 --width-factor \"0.2\" --border 2 --margin 20 --fixed-height --prompt \"\" --prefix \">\" --line-height 20 --ch 15'";

        keybindings = let
          inherit (swayConfig) left down up right menu terminal modifier;
          mod = modifier;
        in
          {
            "${mod}+Return" = "exec ${terminal}";
            "${mod}+Shift+Return" = "exec kitty";

            "${mod}+Shift+q" = "kill";
            "${mod}+space" = "exec ${menu}";

            #"${mod}+${left}" = "focus left";
            #"${mod}+${down}" = "focus down";
            #"${mod}+${up}" = "focus up";
            #"${mod}+${right}" = "focus right";

            #"${mod}+Left" = "focus left";
            #"${mod}+Down" = "focus down";
            #"${mod}+Up" = "focus up";
            #"${mod}+Right" = "focus right";

            #"${mod}+Shift+${left}" = "move left";
            #"${mod}+Shift+${down}" = "move down";
            #"${mod}+Shift+${up}" = "move up";
            #"${mod}+Shift+${right}" = "move right";

            #"${mod}+Shift+Left" = "move workspace to output left";
            #"${mod}+Shift+Up" = "move workspace to output up";
            #"${mod}+Shift+Down" = "move workspace to output down";
            #"${mod}+Shift+Right" = "move workspace to output right";

            "${mod}+Shift+space" = "floating toggle, sticky toggle";
            #"${mod}+space" = "focus mode_toggle";

            #"${mod}+1" = "workspace number 1";
            #"${mod}+2" = "workspace number 2";
            #"${mod}+3" = "workspace number 3";
            #"${mod}+4" = "workspace number 4";
            #"${mod}+5" = "workspace number 5";
            #"${mod}+6" = "workspace number 6";
            #"${mod}+7" = "workspace number 7";
            #"${mod}+8" = "workspace number 8";
            #"${mod}+9" = "workspace number 9";
            #"${mod}+0" = "workspace number 10";

            #"${mod}+Shift+1" = "move container to workspace number 1";
            #"${mod}+Shift+2" = "move container to workspace number 2";
            #"${mod}+Shift+3" = "move container to workspace number 3";
            #"${mod}+Shift+4" = "move container to workspace number 4";
            #"${mod}+Shift+5" = "move container to workspace number 5";
            #"${mod}+Shift+6" = "move container to workspace number 6";
            #"${mod}+Shift+7" = "move container to workspace number 7";
            #"${mod}+Shift+8" = "move container to workspace number 8";
            #"${mod}+Shift+9" = "move container to workspace number 9";
            #"${mod}+Shift+0" = "move container to workspace number 10";

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
            "${mod}+Shift+v" = "exec ${getExe pkgs.nwg-bar} -x";
            "${mod}+Print" = ''mode "${mode_record}"'';

            "${mod}+r" = "mode resize";

            "${mod}+Shift+Delete" = ''exec ${getExe triggerLock}'';
            #"${mod}+k" = "exec ${pkgs.mako}/bin/makoctl dismiss";
            #"${mod}+Shift+k" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";

            #"${mod}+z" = "exec ${pkgs.zathura}/bin/zathura";

            "${mod}+Shift+minus" = "move container to scratchpad";
            "${mod}+minus" = "scratchpad show";
          };

        modes = let
          terminal = swayConfig.terminal;
          Escape = "mode default";
        in {
          resize = let
            Left = "resize shrink width 10 px or 10 ppt";
            Right = "resize grow width 10 px or 10 ppt";
            Up = "resize shrink height 10 px or 10 ppt";
            Down = "resize grow height 10 px or 10 ppt";
          in {
            inherit Left Right Up Down Escape;
            h = Left;
            j = Down;
            k = Up;
            l = Right;
            Return = Escape;
          };

          # TODO explore editing after taking with pciture with swappy
          "${mode_record}" = {
            "p" = ''exec ${getExe pkgs.slurp} | ${getExe pkgs.grim} -g- $(${getBin pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/$(${getBin pkgs.coreutils-full}/bin/date +'%Y-%m-%d-%H%M%S_grim.png') && notify-send -u low alert "screenshot taken", mode "default"'';
            "f" = ''${getExe pkgs.grim} $(${getBin pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/$(${getBin pkgs.coreutils-full}/bin/date +'%Y-%m-%d-%H%M%S_grim.png') && notify-send -u low alert "screenshot taken", mode "default"'';
            Return = Escape;
            Escape = Escape;
          };
        };

        startup = [
          # following needed to launch root apps
          # can be disabled with `xhost -si:localhost:root`
          # ideally we would enable and disable as needed
          # This doesn't work here so I'm just leaving it atm
          # until I care to figure out how to declare this
          # in a way I like
          #{ command = "${pkgs.xorg.xhost}/bin/xhost si:localhost:root"; }

          #{ command = "${pkgs.foot}/bin/foot --server"; }
          #{ command = "${pkgs.mako}/bin/mako"; }
          #{ command = "${pkgs.nextcloud-client}/bin/nextcloud"; }
          #{ command = "${pkgs.keepassxc}/bin/keepassxc"; }
          #{ command = "${getExe pkgs.nwg-panel}"; }
          #{ command = "${config.programs.firefox.package}/bin/firefox"; }
          #{ command = "${pkgs.foot}/bin/foot --title weechat --app-id weechat weechat"; }
          #{ command = "${pkgs.slack}/bin/slack"; }
          #{ command = "${pkgs.element-desktop-wayland}/bin/element-desktop"; }
          #{ command = "${pkgs.spotify}/bin/spotify"; }
          {command = "discord";}
        ];

        assigns = {
          "1" = [
            { app_id = "firefox"; }
          ];
          "10" = [
            { class = "discord"; }
          ];
          #"8" = [
          #  { app_id = "weechat"; }
          #  { class = "Slack"; }
          #  { app_id = "Element"; }
          #];
        };

        #workspaceOutputAssign = mkIf (hostName == "sirius") [
        #  { workspace = "1"; output = "Unknown LCD QHD 1 110503_3"; }
        #  { workspace = "2"; output = "Unknown LCD QHD 1 110503_3"; }
        #  { workspace = "8"; output = "Goldstar Company Ltd W2363D 0000000000"; }
        #  { workspace = "10"; output = "Goldstar Company Ltd W2363D 0000000000"; }
        #];
      };
      # available in next home-manager
      #extraConfigEarly = ''
      #  set $mode_system "System:  [s]oft reboot [r]eboot  [p]oweroff  [l]ogout  [f]irmware"
      #  set $mode_record "Capture: [p]icture or [enter] to leave mode this mode"
      #'';

      extraConfig = ''
        seat seat0 xcursor_theme ${theme.cursor.name} ${toString theme.cursor.size}
        default_border pixel 2
        workspace 1
      '';
    };

    home.file."${config.xdg.configHome}/nwg-bar/bar.json".text = let
      gdmSwitchUser = if nixosConfig.services.xserver.displayManager.gdm.enable then ''
          ,{
            "label": "Switch User",
            "exec": "${pkgs.gdm}/bin/gdmflexiserver",
            "icon": "${pkgs.kdePackages.breeze-icons}/share/icons/breeze-dark/actions/32@3x/system-switch-user.svg"
          }
        '' else "";
    in ''      [
       {
         "label": "Lock",
         "exec": "${lockCmd}",
         "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-lock-screen.svg"
       },
       {
         "label": "Logout",
         "exec": "swaymsg exit",
         "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-log-out.svg"
       },
       {
         "label": "Suspend",
         "exec": "systemctl suspend",
         "icon": "${pkgs.kdePackages.breeze-icons}/share/icons/breeze-dark/actions/32@3x/system-suspend.svg"
       },
       {
         "label": "Reboot",
         "exec": "systemctl reboot",
         "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg"
       },
       {
         "label": "Shutdown",
         "exec": "systemctl -i poweroff",
         "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-shutdown.svg"
       }
       ${gdmSwitchUser}
      ]
    '';

    #programs.swaylock.settings = {
    #  show-failed-attempts = true;
    #  daemonize = true;
    #  image = "${fbk-blurred}";
    #  scaling = "fill";
    #};

    services.swayidle = {
      enable = true;
      timeouts = let
        timeouts = settings.timeouts;
      in [
        { timeout = timeouts.screenLock; command = "${getExe lockCmd}"; }
        {
          timeout = timeouts.displayOff;
          #command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          command = ''${getExe displayOnOffCmd} off'';
          #resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
          resumeCommand = ''${getExe displayOnOffCmd} on'';
        }
      ];
      events = [
        { event = "lock"; command = "${getExe lockCmd}"; }
        { event = "before-sleep"; command = "${getExe lockCmd}"; }
      ];
    };
  };
}
