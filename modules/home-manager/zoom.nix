{
  config,
  pkgs,
  nixosConfig,
  lib,
  inputs,
  ...
}: let
  cfg = config.programs.zoom-us;
in {
  options = {
    programs.zoom-us.enable = lib.mkEnableOption "Enable Zoom-us application and settings";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zoom-us
      pulseaudio # zoom uses pactl
    ];

    wayland.windowManager.sway.config.window.commands = [
      {
        # Zoom audio choice window
        command = "floating enable";
        criteria.title = "Choose ONE of the audio conference options";
      }
      {
        # Zoom "you are connected to computer audio" window
        command = "floating enable";
        criteria.title = "zoom";
      }
      {
        # Zoom meeting window
        command = "inhibit_idle open";
        criteria.title = "Zoom Meeting";
      }
    ];
  };
}
