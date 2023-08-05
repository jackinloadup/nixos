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

    # get swaysock from path
    SWAYSOCK=$(fd sway-ipc /run/user/$UID/ -1)

    if [ -z "$SWAYSOCK" ]; then
        echo "No sway socket found"
        exit 1
    fi

    if [ -z "$1" ]; then
        echo "No argument supplied"
        echo "Usage: $PROGNAME [desk|altwork]"
        exit 1
    fi

    # help
    if [ "$1" == "help" ]; then
        echo "Usage: $PROGNAME [desk|altwork]"
        exit 0
    fi

    if [ "$1" == "desk" ]; then
        swaymsg -s $SWAYSOCK "output DP-2 enable, output DP-1 disable"
        exit 0
    fi

    if [ "$1" == "altwork" ]; then
        swaymsg -s $SWAYSOCK "output DP-1 enable, output DP-2 disable"
        bluetoothctl connect E0:EB:40:F1:95:21
        exit 0
    fi
  '';
in {
  config = {
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
  };
}
