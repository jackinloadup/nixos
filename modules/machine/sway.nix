{ lib, pkgs, config, ... }:
with lib;
{
  imports = [ ];

  options.machine.windowManagers = mkOption {
    type = with types; nullOr (listOf (enum [ "sway" ]));
  };

  config = mkIf (builtins.elem "sway" config.machine.windowManagers) {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        alacritty # look into foot term for ram usage

        wev
        wdisplays

        bemenu
        j4-dmenu-desktop

        qt5.qtwayland # make conditional?
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
      '';
    };

    # This is needed for applications launched outside of the sway pts???
    #disabling to see if that get gdm working
    #environment.variables = {
    #  XDG_SESSION_TYPE = "wayland";
    #  XDG_CURRENT_DESKTOP = "sway";
    #};

    xdg = {
      portal = {
        enable = true;
        gtkUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
       #   xdg-desktop-portal-gtk
        ];
      };
    };
  };
}
