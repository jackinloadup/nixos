{ self, inputs, pkgs, lib, config, ... }:

with lib;
let
  swayConfig = config.wayland.windowManager.sway.config;
  kodiSplash = "${pkgs.kodi-wayland}/share/kodi/media/splash.jpg";
in {
  imports = [
    ../../home-manager/foot.nix
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      WAYLAND_DISPLAY=wayland-1
    '';
    profileExtra = ''
      if shopt -q login_shell; then
          export XDG_RUNTIME_DIR=/run/user/1001
          [[ -f ~/.bashrc ]] && source ~/.bashrc
          [[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]] && exec ${pkgs.sway}/bin/sway &> /tmp/woot
      else
          exit 1 # Somehow this is a non-bash or non-login shell.
      fi
    '';
  };
  #programs.kodi.package = (pkgs.kodi-wayland.override{
  #  joystickSupport = false;
  #  x11Support = false;
  #  nfsSupport = false;
  #  sambaSupport = false;
  #});

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
      };
    };
  };
}
