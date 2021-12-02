{ config, pkgs, nixosConfig, lib, inputs, ... }:
{
  home.packages = with pkgs; lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) [
    zoom-us
    pulseaudio # zoom uses pactl
  ];

  wayland.windowManager.sway.config.window.commands = [
    { # Zoom audio choice window
      command = "floating enable";
      criteria.title = "Choose ONE of the audio conference options";
    }
    { # Zoom "you are connected to computer audio" window
      command = "floating enable";
      criteria.title = "zoom";
    }
    { # Zoom meeting window
      command = "inhibit_idle open";
      criteria.title = "Zoom Meeting";
    }
  ];
}
