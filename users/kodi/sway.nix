{ self, inputs, pkgs, lib, config, ... }:

with lib;
let
  swayConfig = config.wayland.windowManager.sway.config;
  kodiSplash = "${pkgs.kodi-wayland}/share/kodi/media/splash.jpg";
in {
  imports = [
    ../../home-manager/foot.nix
  ];

  config = {

    home.packages = with pkgs; [
      sway

      # Input debugging
      wev
      evtest
    ];

    programs.bash = {
      enable = true;
      # I would like to test if this is needed. It isn't exported so what does
      # that mean and why doesn't it work if used in sessionVariables which
      # i think is the same but exported??
      # Runs after profileExtra
      initExtra = ''
        WAYLAND_DISPLAY=wayland-1
        # SWAYSOCK needs to be set after sway is started
        SWAYSOCK="$XDG_RUNTIME_DIR/sway-ipc.$(id -u).$(pgrep -x sway).sock"
      '';
      # Runs before profileExtra
      sessionVariables = {
        #WAYLAND_DISPLAY = "wayland-1";
        XDG_RUNTIME_DIR = "/run/user/$(id -u)";
      };
      profileExtra = ''
        if shopt -q login_shell; then
            [[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]] && exec ${pkgs.sway}/bin/sway &> /tmp/sway.log
        else
            exit 1 # Somehow this is a non-bash or non-login shell.
        fi
      '';
    };

    #programs.xwayland.enable = true;
    wayland.windowManager.sway = {
      enable = true;
      package = null; # don't override system-installed one
      wrapperFeatures.gtk = true;
      xwayland = false;
      config = {
        left = "h";
        down = "j";
        up = "k";
        right = "l";

        modifier = "Mod4";
        terminal = "${pkgs.foot}/bin/foot";

        input = import ../../home-manager/sway/input.nix;
        startup = [
          {
            command = "${pkgs.kodi-wayland}/bin/kodi";
          }
        ];
        output = {
          "*".bg = ''${kodiSplash} fill'';
        };
        bars = [];
        seat = {
          "*" = { hide_cursor = "3000"; };
        };
        keybindings = let
          inherit (swayConfig) modifier terminal;
          mod = modifier;
        in {
          "${mod}+Return" = "exec ${terminal}";
          "${mod}+Shift+q" = "kill";
          "--inhibited --no-repeat XF86Eject" = "exec ${pkgs.procps}/bin/pkill -9 kodi-wayland & ${pkgs.kodi-wayland}/bin/kodi";
        };
      };
    };
  };
}
