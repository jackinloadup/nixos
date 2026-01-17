{ pkgs
, lib
, flake
, ...
}:
let
  inherit (lib) mkDefault;
in
{
  config = {
    environment.systemPackages = [ pkgs.xwayland-satellite ];

    security.pam.services.swaylock = {
      text = "auth include login";
      enableGnomeKeyring = true;
      sshAgentAuth = true;
    };

    programs.niri.package = pkgs.niri-unstable;

    home-manager.sharedModules = [
      ({ config, ... }:
        let
          inherit (lib) getBin getExe mkIf;

          xcursor_theme = config.gtk.cursorTheme.name;
          termCmd = "${getExe pkgs.kitty}";
          #menu = "${getExe pkgs.j4-dmenu-desktop} --no-generic --term='${termCmd}' --dmenu='${getExe pkgs.bemenu} --ignorecase --list 10 --center --border-radius 12 --width-factor \"0.2\" --border 2 --margin 20 --fixed-height --prompt \"\" --prefix \">\" --line-height 20 --ch 15'";
          noctalia-shell = "${getExe flake.inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}";
          menu = "${noctalia-shell} ipc call launcher toggle";
        in
        {
          imports = [ flake.inputs.niri.homeModules.niri ];

          config = mkIf config.programs.niri.enable {
            # try with niri
            #services.flameshot = {
            #  enable = true;
            #};
            programs.kitty.enable = true;
            programs.noctalia-shell.enable = true;

            # Idle and lock screen configuration (replaces hypridle/hyprlock)
            services.swayidle = {
              enable = true;
              events = [
                { event = "lock"; command = "${getExe pkgs.swaylock-effects} -f"; }
                { event = "before-sleep"; command = "${getExe pkgs.swaylock-effects} -f"; }
                { event = "after-resume"; command = "${getExe pkgs.niri} msg action power-on-monitors"; }
              ];
              timeouts = [
                { timeout = 300; command = "${getExe pkgs.swaylock-effects} -f"; }
                {
                  timeout = 360;
                  command = "${getExe pkgs.niri} msg action power-off-monitors";
                  resumeCommand = "${getExe pkgs.niri} msg action power-on-monitors";
                }
              ];
            };

            programs.swaylock = {
              enable = true;
              package = pkgs.swaylock-effects;
              settings = {
                image = "${config.home.homeDirectory}/Pictures/background.jpg";
                clock = true;
                timestr = "%I:%M";
                datestr = "%A, %B %d";
                indicator = true;
                indicator-radius = 100;
                indicator-thickness = 7;
                #effect-blur = "7x5";
                grace = 0;
                fade-in = 0.2;

                font-size = 32;
              };
            };

            programs.niri = {
              settings = {
                input = {
                  keyboard = {
                    #xkb = {
                    #  layout = "us,se";
                    #  model = "pc105";
                    #  options = "ctrl:nocaps,grp:switch,compose:rctrl";
                    #};
                    repeat-delay = 300;
                    repeat-rate = 20;
                  };
                  touchpad = {
                    tap = true;
                    dwt = true;
                    natural-scroll = false;
                  };
                  focus-follows-mouse.enable = true;
                  focus-follows-mouse.max-scroll-amount = "0%";
                  workspace-auto-back-and-forth = true;
                };

                spawn-at-startup = [
                  #{
                  #  command = [
                  #    "systemctl"
                  #    "--user"
                  #    "start"
                  #    "waybar.service"
                  #  ];
                  #}

                  # {
                  #   sh = "${noctalia}/bin/noctalia-shell";
                  # }
                  #{sh = "${noctaliaInit}/bin/noctalia-init";}
                  #{sh = "systemctl restart --user kanshi.service";}
                  # use systemd --user wpaperd
                  #{ sh = "${pkgs.wpaperd}/bin/wpaperd --daemon"; }
                ];

                hotkey-overlay.skip-at-startup = true;

                cursor = {
                  theme = xcursor_theme;
                };

                # LG 4k 42in
                outputs."DP-2".scale = mkDefault 1.0;
                # laptop monitor
                outputs."eDP-1".scale = mkDefault 1.0;

                prefer-no-csd = true;

                layout = {
                  gaps = 16;
                  center-focused-column = "never";
                  preset-column-widths = [
                    { proportion = 1.0 / 3.0; }
                    { proportion = 1.0 / 2.0; }
                    { proportion = 2.0 / 3.0; }
                  ];
                  default-column-width = { proportion = 0.5; };

                  tab-indicator = {
                    gap = 8;
                    gaps-between-tabs = 4;
                    corner-radius = 8;
                    width = 10;
                    position = "top";
                  };

                  focus-ring = {
                    width = 1;

                    active = {
                      color = "#7fc8ff";
                    };

                    inactive = {
                      color = "#505050";
                    };
                  };

                  border = {
                    enable = true;
                    width = 1;
                  };
                  shadow = {
                    enable = true;
                    softness = 30;
                    spread = 5;
                    offset = {
                      x = 0;
                      y = 5;
                    };
                    color = "#0007";
                  };

                  struts = {
                    left = 8;
                    right = 8;
                    top = 8;
                    bottom = 8;
                  };
                };

                screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H.%M.%S.png";

                window-rules = [
                  {
                    geometry-corner-radius = {
                      top-left = 12.0;
                      top-right = 12.0;
                      bottom-left = 12.0;
                      bottom-right = 12.0;
                    };
                    clip-to-geometry = true;
                  }

                  {
                    matches = [
                      {
                        app-id = "firefox$";
                        title = "^Picture-in-Picture$";
                      }
                    ];
                    open-floating = true;
                  }
                ];

                # for noctalia
                #debug {
                #  // Allows notification actions and window activation from Noctalia.
                #  honor-xdg-activation-with-invalid-serial
                #}

                binds = {
                  "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
                  "Mod+Return".action.spawn = [ "${termCmd}" ];
                  "Mod+Shift+Return".action.spawn = [ "${getBin pkgs.foot}/bin/footclient" "--client-environment" ];
                  "Mod+Shift+E".action.spawn = [ "${noctalia-shell}" "ipc" "call" "launcher" "emoji" ];
                  # "Mod+D".action.spawn = "fuzzel";
                  #"Mod+D".action.spawn-sh = "${noctaliaIPC} launcher toggle";
                  #"Mod+Alt+L".action.spawn-sh = "${noctaliaIPC} lockScreen lock";
                  "Mod+Alt+L".action.spawn = [ "loginctl" "lock-session" ];

                  # handing media via lowLevelXF86keys and actkbd
                  #"XF86AudioRaiseVolume" = {
                  #  action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];
                  #  allow-when-locked = true;
                  #};
                  #"XF86AudioLowerVolume" = {
                  #  action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
                  #  allow-when-locked = true;
                  #};
                  #"XF86AudioMute" = {
                  #  action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
                  #  allow-when-locked = true;
                  #};
                  #"XF86AudioMicMute" = {
                  #  action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
                  #  allow-when-locked = true;
                  #};

                  "Mod+Tab".action.toggle-overview = [ ];

                  "Mod+Shift+Q".action.close-window = [ ];

                  "Mod+Left".action.focus-column-left = [ ];
                  "Mod+Down".action.focus-window-or-workspace-down = [ ];
                  "Mod+Up".action.focus-window-or-workspace-up = [ ];
                  "Mod+Right".action.focus-column-right = [ ];
                  "Mod+H".action.focus-column-left = [ ];
                  "Mod+J".action.focus-window-down = [ ];
                  "Mod+K".action.focus-window-up = [ ];
                  "Mod+L".action.focus-column-right = [ ];

                  "Mod+Ctrl+Left".action.move-column-left = [ ];
                  "Mod+Ctrl+Down".action.move-window-down = [ ];
                  "Mod+Ctrl+Up".action.move-window-up = [ ];
                  "Mod+Ctrl+Right".action.move-column-right = [ ];
                  "Mod+Ctrl+H".action.move-column-left = [ ];
                  "Mod+Ctrl+J".action.move-window-down = [ ];
                  "Mod+Ctrl+K".action.move-window-up = [ ];
                  "Mod+Ctrl+L".action.move-column-right = [ ];

                  "Mod+Home".action.focus-column-first = [ ];
                  "Mod+End".action.focus-column-last = [ ];
                  "Mod+Ctrl+Home".action.move-column-to-first = [ ];
                  "Mod+Ctrl+End".action.move-column-to-last = [ ];

                  #"Mod+Shift+Left".action.focus-monitor-left = [];
                  #"Mod+Shift+Down".action.focus-monitor-down = [];
                  #"Mod+Shift+Up".action.focus-monitor-up = [];
                  #"Mod+Shift+Right".action.focus-monitor-right = [];
                  #"Mod+Shift+H".action.focus-monitor-left = [];
                  #"Mod+Shift+J".action.focus-monitor-down = [];
                  #"Mod+Shift+K".action.focus-monitor-up = [];
                  #"Mod+Shift+L".action.focus-monitor-right = [];

                  "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
                  "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
                  "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
                  "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
                  "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
                  "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
                  "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
                  "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

                  "Mod+Page_Down".action.focus-workspace-down = [ ];
                  "Mod+Page_Up".action.focus-workspace-up = [ ];
                  "Mod+U".action.focus-workspace-down = [ ];
                  "Mod+I".action.focus-workspace-up = [ ];
                  "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
                  "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
                  "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
                  "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

                  "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
                  "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
                  "Mod+Shift+U".action.move-workspace-down = [ ];
                  "Mod+Shift+I".action.move-workspace-up = [ ];

                  "Mod+Shift+H".action.swap-window-left = [ ];
                  "Mod+Shift+L".action.swap-window-right = [ ];
                  "Mod+Shift+Left".action.swap-window-left = [ ];
                  "Mod+Shift+Right".action.swap-window-right = [ ];

                  "Mod+WheelScrollDown" = {
                    action.focus-workspace-down = [ ];
                    cooldown-ms = 150;
                  };
                  "Mod+WheelScrollUp" = {
                    action.focus-workspace-up = [ ];
                    cooldown-ms = 150;
                  };
                  "Mod+Ctrl+WheelScrollDown" = {
                    action.move-column-to-workspace-down = [ ];
                    cooldown-ms = 150;
                  };

                  "Mod+Ctrl+WheelScrollUp" = {
                    action.move-column-to-workspace-up = [ ];
                    cooldown-ms = 150;
                  };

                  "Mod+MouseMiddle".action.toggle-overview = [ ];

                  "Mod+WheelScrollRight".action.focus-column-right = [ ];
                  "Mod+WheelScrollLeft".action.focus-column-left = [ ];
                  "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
                  "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

                  "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
                  "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
                  "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
                  "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

                  "Mod+1".action.focus-workspace = 1;
                  "Mod+2".action.focus-workspace = 2;
                  "Mod+3".action.focus-workspace = 3;
                  "Mod+4".action.focus-workspace = 4;
                  "Mod+5".action.focus-workspace = 5;
                  "Mod+6".action.focus-workspace = 6;
                  "Mod+7".action.focus-workspace = 7;
                  "Mod+8".action.focus-workspace = 8;
                  "Mod+9".action.focus-workspace = 9;

                  "Mod+Shift+1".action.move-column-to-workspace = 1;
                  "Mod+Shift+2".action.move-column-to-workspace = 2;
                  "Mod+Shift+3".action.move-column-to-workspace = 3;
                  "Mod+Shift+4".action.move-column-to-workspace = 4;
                  "Mod+Shift+5".action.move-column-to-workspace = 5;
                  "Mod+Shift+6".action.move-column-to-workspace = 6;
                  "Mod+Shift+7".action.move-column-to-workspace = 7;
                  "Mod+Shift+8".action.move-column-to-workspace = 8;
                  "Mod+Shift+9".action.move-column-to-workspace = 9;

                  "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
                  "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

                  "Mod+Comma".action.consume-window-into-column = [ ];
                  "Mod+Period".action.expel-window-from-column = [ ];

                  # Resize
                  "Mod+R".action.switch-preset-column-width = [ ];
                  "Mod+Shift+R".action.switch-preset-window-height = [ ];
                  "Mod+Ctrl+R".action.reset-window-height = [ ];

                  # Full screen
                  "Mod+F".action.maximize-column = [ ];
                  "Mod+Shift+F".action.fullscreen-window = [ ];

                  # https://github.com/sodiboo/niri-flake/pull/1382
                  #"Mod+Ctrl+F".action.maximize-window-to-edges = [];

                  "Mod+C".action.center-column = [ ];

                  "Mod+W".action.toggle-column-tabbed-display = [ ];

                  #"Mod+Shift+w".action.spawn = ["sh" "-c" "${openZellijSession}/bin/open-zellij-session"];
                  #"Mod+Minus".action.spawn = ["sh" "-c" "${pkgs.scripts}/bin/rofi-rbw"];
                  #"Mod+Shift+Minus".action.spawn = ["sh" "-c" "passonly=y ${pkgs.scripts}/bin/rofi-rbw"];
                  #"Mod+Shift+Equal".action.spawn = ["sh" "-c" "codeonly=y ${pkgs.scripts}/bin/rofi-rbw"];
                  "Mod+Space".action.spawn = [ "sh" "-c" "${menu}" ];

                  "Print".action.screenshot = [ ];
                  "Ctrl+Print".action.screenshot-screen = [ ];
                  "Alt+Print".action.screenshot-window = [ ];

                  "Mod+Escape" = {
                    allow-inhibiting = false;
                    action.toggle-keyboard-shortcuts-inhibit = [ ];
                  };

                  # "Mod+p".action.spawn = ["sh" "-c" "${systemMenu}/bin/niri-system-menu"];
                  #"Mod+p".action.spawn-sh = "${noctaliaIPC} sessionMenu toggle";

                  "Ctrl+Alt+Delete".action.quit = [ ];

                  "Mod+Shift+P".action.power-off-monitors = [ ];
                };
              };
            };
            xdg = {
              portal = {
                enable = true;
                extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
                config.niri = {
                  default = [ "gnome" ];
                  "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
                };
              };
            };
          };
        })
    ];
  };
}
