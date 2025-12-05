{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption types mkDefault;
  inherit (builtins) elem;
in {
  imports = [];

  #config = mkIf (elem "sway" config.machine.windowManagers) {
  config = mkIf config.programs.sway.enable {
 #   environment.sessionVariables = {
 #     # Hint to electron apps to use wayland
 #     NIXOS_OZONE_WL = "1";
 #   };
    # I think this comes for free when enabling programs.sway.enable
    #programs.xwayland.enable = mkDefault true;

    #services.seatd.enable = true;


    programs.sway = {
      #package = pkgs.stable.sway;
      wrapperFeatures.gtk = mkDefault true;
      extraPackages = [
        pkgs.swaylock
        pkgs.swayidle

        pkgs.bemenu
        pkgs.j4-dmenu-desktop
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
        enable = mkDefault true;
        extraPortals = mkIf (!config.services.desktopManager.gnome.enable) [
          pkgs.xdg-desktop-portal-gtk # Desktop integration portals for sandboxed apps
          pkgs.xdg-desktop-portal-shana # A filechooser portal backend for any desktop environment
        ];
        wlr = {
          enable = mkDefault true;
          settings = {
            screencast = {
            #  OUTPUT_NAME = "HDMI-A-1";
            #  MAX_FPS = 30;
            #  exec_before = "disable_notifications.sh";
            #  exec_after = "enable_notifications.sh";
              chooser_type = "simple";
              chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
            };
          };
        };
      };
    };
  };
}
