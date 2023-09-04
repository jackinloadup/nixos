{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (builtins) elem;
in {
  imports = [];

  options.machine.windowManagers = mkOption {
    type = with types; nullOr (listOf (enum ["sway"]));
  };

  config = mkIf (elem "sway" config.machine.windowManagers) {
    programs.xwayland.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle

        wev
        wdisplays
        wlr-randr

        bemenu
        j4-dmenu-desktop

        # nheko, mindforger
        #qt5.qtwayland # make conditional?
      ];

      extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_FORCE_DPI=physical
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
        export WLR_DRM_DEVICES=/dev/dri/card0

        export GTK_USE_PORTAL=1
      '';
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = mkIf (!config.services.xserver.desktopManager.gnome.enable) [
          pkgs.xdg-desktop-portal-gtk
        ];
        wlr = {
          enable = true;
          #settings = {
          #  screencast = {
          #    output_name = "HDMI-A-1";
          #    max_fps = 30;
          #    exec_before = "disable_notifications.sh";
          #    exec_after = "enable_notifications.sh";
          #    chooser_type = "simple";
          #    chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          #  };
          #};
        };
      };
    };
  };
}
