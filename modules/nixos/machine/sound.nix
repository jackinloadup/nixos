{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
in {
  config = mkIf config.services.pipewire.enable {
    security.rtkit.enable = true; # Allows pipewire to run "realtime"
    hardware.pulseaudio.enable = false; # Disable pulseaudio

    # Enable pipewire https://nixos.wiki/wiki/PipeWire
    services.pipewire = {
      alsa.enable = false;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;

      # pipewire.config gone in 23.05
      #config.pipewire = {
      #  "context.properties" = {
      #    # debug tuning
      #    #"link.max-buffers" = 64;
      #    #"link.max-buffers" = 16; # version < 3 clients can't handle more than this
      #    #"log.level" = 2; # https://docs.pipewire.org/page_daemon.html
      #    #"default.clock.rate" = 48000;
      #    #"default.clock.quantum" = 1024;
      #    #"default.clock.min-quantum" = 32;
      #    #"default.clock.max-quantum" = 8192;
      #  };
      #};
    };

    # if undistract me is enabled go ahead and use sound
    programs.bash.undistractMe.playSound = true;
    environment.systemPackages = with pkgs; [
      pulseaudio
      #pamixer # TUI volume source/sink manager
      pulsemixer # TUI volume source/sink manager
    ];
  };
}
