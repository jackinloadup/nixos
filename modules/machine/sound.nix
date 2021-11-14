{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
in {
  imports = [ ];

  options.machine.sound = mkEnableOption "Enable sound through pipewire";

  config = mkIf (cfg.sizeTarget > 0 && cfg.sound) {
    sound.enable = false; # Enables ALSA. Conflicts with pipewire?

    security = {
      rtkit.enable = true; # Allows pipewire to run "realtime"
    };

    # Disable pulseaudio
    hardware.pulseaudio.enable = false;
    # Enable pipewire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # if undistract me is enabled go ahead and use sound
    programs.bash.undistractMe.playSound = true;
  };
}
