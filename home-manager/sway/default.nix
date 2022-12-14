{ config, pkgs, nixosConfig, lib, inputs, ... }:

with lib;
let
  settings = import ../../settings;
  hostName = nixosConfig.networking.hostName;
  theme = settings.theme;
  fontConf = {
    names = [ theme.font.mono.family ];
    size = builtins.mul theme.font.size 1.0; # typecast to float
  };
  swayConfig = config.wayland.windowManager.sway.config;
  footTERM = if config.programs.foot.settings ? main.term
    then
      config.programs.foot.settings.main.term
    else "foot";
  termCmd = "${getBin pkgs.foot}/bin/footclient --client-environment";
  mode_system = "System:  [r]eboot  [p]oweroff  [l]ock  [f]irmware [e]xit";
  mode_record = "Capture: [p]icture [f]ullscreen or [enter] to leave mode this mode";

  lockSwayIdle = ''exec ${getBin pkgs.procps}/bin/pkill -SIGUSR1 swayidle'';
in
{
  imports = [
    ../waybar.nix
  ];

  config = mkIf (builtins.elem "sway" nixosConfig.machine.windowManagers) {
    #swayEnabled = nixosConfig.programs.sway.enable;

    programs.foot.enable = true;
    programs.foot.server.enable = true;
    services.dunst.enable = true;

    home.packages = with pkgs; [
      #sway-contrib.grimshot
      wl-clipboard
      #mako
      #dmenu
      gnome.adwaita-icon-theme

      #gksu # gui for root privilages # needed for zenmap # gone in unstable
      # enable  xhost si:localuser:root
      # disable xhost -si:localuser:root
      xorg.xhost # needed to allow root apps to use gui $ xhost si:localuser:root
    ];

    # disabling for now due to i3. This could be started in commands but maybe systemd mod better?
    #services.flameshot.enable = true;

    wayland.windowManager.sway = {
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

        terminal = "TERM=${footTERM} ${termCmd}";

        workspaceAutoBackAndForth = true;

        input = import ./input.nix;
        output = import ./output.nix;
        window = import ./window.nix;
        bars = (import ./bars.nix { inherit config pkgs; } ).bars;
        colors = (import ./colors.nix { inherit config pkgs; } ).colors;

        floating.criteria = [{ class = "^Wine$"; }];

        menu = "${getExe pkgs.j4-dmenu-desktop} --no-generic --term='${termCmd}' --dmenu='${getExe pkgs.bemenu} -i -l 10'" ;

        keybindings = let
          inherit (swayConfig) left down up right menu terminal modifier;
          mod = modifier;
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

          "${mod}+Shift+space" = "floating toggle, sticky toggle";
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
          "${mod}+Shift+v" = ''mode "${mode_system}"'';
          "${mod}+Print" = ''mode "${mode_record}"'';

          "${mod}+r" = "mode resize";

          "${mod}+Shift+Delete" = lockSwayIdle;
          #"${mod}+k" = "exec ${pkgs.mako}/bin/makoctl dismiss";
          #"${mod}+Shift+k" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";

          #"${mod}+z" = "exec ${pkgs.zathura}/bin/zathura";

          "${mod}+Shift+minus" = "move container to scratchpad";
          "${mod}+minus" = "scratchpad show";
        } // (if hostName == "spica" then { # smart. use hostname then append based on that
          "XF86MonBrightnessUp" = "exec ${getExe pkgs.light} -A 10";
          "XF86MonBrightnessDown" = "exec ${getExe pkgs.light} -U 10";
        } else { });

        modes = let
          terminal = swayConfig.terminal;
        in {
          "${mode_system}" = {
            #s = "exec ${terminal} -e ./kexec-systemd.sh";
            r = "exec reboot";
            p = "exec poweroff";
            l = lockSwayIdle;
            e = "exit";
            f = "exec systemctl reboot --firmware-setup";
            Return = "mode default";
            Escape = "mode default";
          };

          resize = let
            Left = "resize shrink width 10 px or 10 ppt";
            Right = "resize grow width 10 px or 10 ppt";
            Up = "resize shrink height 10 px or 10 ppt";
            Down = "resize grow height 10 px or 10 ppt";
            Escape = "mode default";
          in {
            inherit Left Right Up Down Escape;
            h = Left;
            j = Down;
            k = Up;
            l = Right;
            Return = Escape;
          };

          "${mode_record}" = {
            "p" = ''exec ${getExe pkgs.slurp} | ${getExe pkgs.grim} -g- $(${getBin pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/$(${getBin pkgs.coreutils-full}/bin/date +'%Y-%m-%d-%H%M%S_grim.png') && notify-send -u low alert "screenshot taken", mode "default"'';
            "f" = ''${getExe pkgs.grim} $(${getBin pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/$(${getBin pkgs.coreutils-full}/bin/date +'%Y-%m-%d-%H%M%S_grim.png') && notify-send -u low alert "screenshot taken", mode "default"'';
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
          {
            command =
              let
                lockCmd = "'${getExe pkgs.swaylock} -f -i \"$(${getBin pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/background.jpg\"'";
                timeouts = settings.timeouts;
              in
              ''${getExe pkgs.swayidle} -w \
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
  };
}
