{
  self,
  inputs,
  pkgs,
  lib,
  ...
}: let
  script = pkgs.writeShellScript "switch-desktop" ''
    # strict
    set -euo pipefail

    # debug
    set -x

    readonly PROGNAME="$(basename "$0")"


    main() {
      local DESK="$1"
      local WM="$XDG_SESSION_DESKTOP"
      local DISPLAY_ALTWORK="DP-1"
      local DISPLAY_DESK="DP-2"

      usage
      case $WM in
        "sway")
          control_sway
          ;;

        "hyprland")
          control_hyprland
          ;;

        "niri")
          control_niri
          ;;

        *)
          echo "Window manager `$WM` not supported"
          echo "Please modify script to support it"
          exit 1
          ;;
      esac

    }

    usage() {
       if [ -z "$DESK" ]; then
           echo "No argument supplied"
           echo "Usage: $PROGNAME [desk|altwork]"
           exit 1
       fi

       if [ -z "$WM" ]; then
           echo "No WM detected"
           echo "Please set XDG_SESSION_DESKTOP"
           exit 1
       fi
    }

    control_sway() {
      # get swaysock from path
      SWAYSOCK=$(fd sway-ipc /run/user/$UID/ -1)

      if [ -z "$SWAYSOCK" ]; then
          echo "No sway socket found"
          exit 1
      fi

      if [ "$DESK" == "desk" ]; then
          swaymsg -s $SWAYSOCK "output $DISPLAY_DESK enable, output $DISPLAY_ALTWORK disable"
          exit 0
      fi

      if [ "$DESK" == "altwork" ]; then
          swaymsg -s $SWAYSOCK "output $DISPLAY_ALTWORK enable, output $DISPLAY_DESK disable"
          exit 0
      fi
    }

    control_hyprland() {
      if [ "$DESK" == "desk" ]; then
          hyprctl keyword monitor $DISPLAY_DESK,enable
          hyprctl keyword monitor $DISPLAY_ALTWORK,disable
          exit 0
      fi

      if [ "$DESK" == "altwork" ]; then
          hyprctl keyword monitor $DISPLAY_ALTWORK,enable
          hyprctl keyword monitor $DISPLAY_DESK,disable
          exit 0
      fi
    }

    control_niri() {
        # get niri socket from path
        export NIRI_SOCKET
        NIRI_SOCKET=$(fd --exact-depth 1 niri /run/user/$UID/ -1)

        if [ "$DESK" == "desk" ]; then
            niri msg output $DISPLAY_DESK on
            niri msg output $DISPLAY_ALTWORK off
            exit 0
        fi

        if [ "$DESK" == "altwork" ]; then
            niri msg output $DISPLAY_ALTWORK on
            niri msg output $DISPLAY_DESK off
            exit 0
        fi
    }


    # Not sure what bluetooth device I was connecting anymore
    connect_bluetooth() {
      bluetoothctl connect E0:EB:40:F1:95:21
    }

    main $@
  '';

  package = pkgs.stdenv.mkDerivation {
     name = "switch-desktop";
     builder = script;
  };
in {
  config = {
    home-manager.sharedModules = [
      {
        #home.packages = [ script ];

        xdg.desktopEntries = {
          switch-to-desk = {
            name = "Desk";
            genericName = "Change to Desk";
            comment = "Change to Desk";
            exec = "${script} desk";
            terminal = false;
            categories = [
              "Utility"
            ];
          };
          switch-to-altwork = {
            name = "Altwork";
            genericName = "Change to Altwork";
            comment = "Change to Altwork";
            exec = "${script} altwork";
            terminal = false;
            categories = [
              "Utility"
            ];
          };
        };
      }
    ];
  };
}
