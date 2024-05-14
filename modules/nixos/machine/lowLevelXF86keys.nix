{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption mkDefault getExe getBin optionals types;
  cfg = config.machine.lowLevelXF86keys;
  settings = import ../../../settings;
in {
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

    sound.mediaKeys.enable = mkDefault false; # uses alsa amixer by default

    # Enable if minimal setup. Dont use for Gnome/KDE/Xfce
    #sound.mediaKeys.enable = true; # uses alsa amixer by default
    services.actkbd = let
      user_run = "/run/user/${toString settings.user.uid}";
      dbus = "DBUS_SESSION_BUS_ADDRESS=unix:path=${user_run}/bus";
      dunstify = "${dbus} ${getBin pkgs.dunst}/bin/dunstify --replace=${toString settings.user.uid} --timeout=2000";
      bash = "${getBin pkgs.su}/bin/su ${settings.user.username} -s ${getExe pkgs.bash}";
      playerctl = "${dbus} ${getExe pkgs.playerctl} --player=spotify,%any";
      pactl = "${getBin pkgs.pulseaudio}/bin/pactl -s ${user_run}/pulse/native";

      # get mute as 0=yes,mutted 1=no,umutted
      is_mute = "${pactl} list sinks | ${getExe pkgs.ripgrep} -A 7 RUNNING | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.coreutils}/bin/head -1  | ${pkgs.coreutils}/bin/cut -d \"/\" -f2 | ${pkgs.coreutils}/bin/tr -d \" \" | ${getExe pkgs.gnugrep} -q yes";
      # get audio volume as percent int eg 80
      current_volume = "${pactl} list sinks | ${getExe pkgs.ripgrep} -A 8 RUNNING | ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.coreutils}/bin/head -1  | ${pkgs.coreutils}/bin/cut -d \"/\" -f2 | ${pkgs.coreutils}/bin/tr -d \" %\"";
      set_volume_mute = "${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
      set_volume_up = "${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
      set_volume_down = "${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
      notify_current_volume = "${dunstify} \"Volume\" -h int:value:`${current_volume}` --urgency low --icon audio-speakers &";
      notify_muted = "${dunstify} \"Volume Muted\" -t 0 -h int:value:0 --urgency low --icon audio-speakers &";
    in {
      enable = true;
      bindings = []
        ++ optionals cfg.brightness [
          {
            keys = [224];
            events = ["key"];
            command = "${getExe pkgs.light} -U 10";
          }
          {
            keys = [225];
            events = ["key"];
            command = "${getExe pkgs.light} -A 10";
          }
        ]
        ++ optionals cfg.volume [
          {
            keys = [113];
            events = ["key"];
            command = "${bash} -c '${set_volume_mute} && ${is_mute} && ${notify_muted} || ${notify_current_volume}'";
          }
          {
            keys = [114];
            events = ["key"];
            command = "${bash} -c '${set_volume_down} && ${notify_current_volume}'";
          }
          {
            keys = [115];
            events = ["key"];
            command = "${bash} -c '${set_volume_up}   && ${notify_current_volume}'";
          }
        ]
        ++ optionals cfg.media [
          {
            keys = [163];
            events = ["key"];
            command = "${bash} -c '${playerctl} next       '";
          }
          {
            keys = [164];
            events = ["key"];
            command = "${bash} -c '${playerctl} play-pause && ${dunstify} \"Play-Pause: \"'";
          }
          {
            keys = [165];
            events = ["key"];
            command = "${bash} -c '${playerctl} previous   '";
          }
        ];
    };
  };
}
