{ lib
, pkgs
, config
, flake
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption getExe getBin optionals types;
  cfg = config.machine.lowLevelXF86keys;
  settings = import ../../../settings;

  user_run = "/run/user/${toString settings.user.uid}";
  dbus = "DBUS_SESSION_BUS_ADDRESS=unix:path=${user_run}/bus";

  noctalia-shell = flake.inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Media control script that uses noctalia-shell for niri, playerctl for others
  media-control = pkgs.writeShellScriptBin "media-control" ''
    ACTION="$1"
    USER_RUN="${user_run}"

    # Check if niri is running by looking for its socket
    if ls "$USER_RUN"/niri.*.sock 1>/dev/null 2>&1; then
      # niri is running, use noctalia-shell
      export XDG_RUNTIME_DIR="$USER_RUN"
      case "$ACTION" in
        play-pause|toggle)
          ${getExe noctalia-shell} ipc call media playPause
          ;;
        next)
          ${getExe noctalia-shell} ipc call media next
          ;;
        previous|prev)
          ${getExe noctalia-shell} ipc call media previous
          ;;
      esac
    else
      # Not niri, use playerctl
      PLAYERCTL="${dbus} ${getExe pkgs.playerctl} --player=spotify,%any"
      case "$ACTION" in
        play-pause|toggle)
          $PLAYERCTL play-pause
          ;;
        next)
          $PLAYERCTL next
          ;;
        previous|prev)
          $PLAYERCTL previous
          ;;
      esac
    fi
  '';

  # Volume control script that uses noctalia-shell for niri, pactl for others
  volume-control = pkgs.writeShellScriptBin "volume-control" ''
    ACTION="$1"
    USER_RUN="${user_run}"

    # Check if niri is running by looking for its socket
    if ls "$USER_RUN"/niri.*.sock 1>/dev/null 2>&1; then
      # niri is running, use noctalia-shell
      export XDG_RUNTIME_DIR="$USER_RUN"
      case "$ACTION" in
        up|increase)
          ${getExe noctalia-shell} ipc call volume increase
          ;;
        down|decrease)
          ${getExe noctalia-shell} ipc call volume decrease
          ;;
        mute)
          ${getExe noctalia-shell} ipc call volume muteOutput
          ;;
      esac
    else
      # Not niri, use pactl + dunstify
      PACTL="${getBin pkgs.pulseaudio}/bin/pactl -s $USER_RUN/pulse/native"
      DUNSTIFY="${dbus} ${getBin pkgs.dunst}/bin/dunstify --replace=${toString settings.user.uid} --timeout=2000"

      get_volume() {
        $PACTL list sinks | ${getExe pkgs.ripgrep} -A 8 RUNNING | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.coreutils}/bin/head -1 | ${pkgs.coreutils}/bin/cut -d "/" -f2 | ${pkgs.coreutils}/bin/tr -d " %"
      }

      is_muted() {
        $PACTL list sinks | ${getExe pkgs.ripgrep} -A 7 RUNNING | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.coreutils}/bin/head -1 | ${pkgs.coreutils}/bin/cut -d "/" -f2 | ${pkgs.coreutils}/bin/tr -d " " | ${getExe pkgs.gnugrep} -q yes
      }

      case "$ACTION" in
        up|increase)
          $PACTL set-sink-volume @DEFAULT_SINK@ +5%
          $DUNSTIFY "Volume" -h int:value:$(get_volume) --urgency low --icon audio-speakers &
          ;;
        down|decrease)
          $PACTL set-sink-volume @DEFAULT_SINK@ -5%
          $DUNSTIFY "Volume" -h int:value:$(get_volume) --urgency low --icon audio-speakers &
          ;;
        mute)
          $PACTL set-sink-mute @DEFAULT_SINK@ toggle
          if is_muted; then
            $DUNSTIFY "Volume Muted" -t 0 -h int:value:0 --urgency low --icon audio-speakers &
          else
            $DUNSTIFY "Volume" -h int:value:$(get_volume) --urgency low --icon audio-speakers &
          fi
          ;;
      esac
    fi
  '';
in
{
  options.machine.lowLevelXF86keys = {
    enable = mkEnableOption "Bulk enable for now";
    media = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system-wide media keys. Play toggle, next, prev";
    };
    volume = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system-wide volume keys. mute toggle, vol up/down";
    };
    brightness = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system-wide brightness keys. Up/Down";
    };
  };

  config = mkIf cfg.enable {
    #TODO light doesn't work for all systems or is needed for all systems
    # Enable backlight control
    programs.light.enable = true;


    # Enable if minimal setup. Dont use for Gnome/KDE/Xfce
    services.actkbd =
      let
        bash = "${getBin pkgs.su}/bin/su ${settings.user.username} -s ${getExe pkgs.bash}";
        volumectl = "${getExe volume-control}";
        mediactl = "${getExe media-control}";
      in
      {
        enable = true;
        bindings = optionals cfg.brightness [
          {
            keys = [ 224 ];
            events = [ "key" ];
            command = "${getExe pkgs.light} -U 10";
          }
          {
            keys = [ 225 ];
            events = [ "key" ];
            command = "${getExe pkgs.light} -A 10";
          }
        ]
        ++ optionals cfg.volume [
          {
            keys = [ 113 ];
            events = [ "key" ];
            command = "${bash} -c '${volumectl} mute'";
          }
          {
            keys = [ 114 ];
            events = [ "key" ];
            command = "${bash} -c '${volumectl} down'";
          }
          {
            keys = [ 115 ];
            events = [ "key" ];
            command = "${bash} -c '${volumectl} up'";
          }
        ]
        ++ optionals cfg.media [
          {
            keys = [ 163 ];
            events = [ "key" ];
            command = "${bash} -c '${mediactl} next'";
          }
          {
            keys = [ 164 ];
            events = [ "key" ];
            command = "${bash} -c '${mediactl} play-pause'";
          }
          {
            keys = [ 165 ];
            events = [ "key" ];
            command = "${bash} -c '${mediactl} previous'";
          }
        ];
      };
  };
}
