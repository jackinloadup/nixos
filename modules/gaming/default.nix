{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.machine;
  settings = import ../../settings;
in {
  imports = [
    ./openrct2.nix
  ];

  options.machine.gaming = mkEnableOption "Enable extra options only needed for gaming";

  config = mkIf cfg.gaming {
    environment.systemPackages = with pkgs; [
      #monado
      #lighthouse-steamvr
      libgdiplus
      gnome.adwaita-icon-theme

      # SNES
      snes9x-gtk

      # xorg stuff
      xorg.xhost # for `xhost si:localuser:root`

      #nur.repos.dukzcry.gamescope
      #retroarch
      #retroarchFull
      cool-retro-term
    ];

    services.xserver = {
      modules = [ pkgs.xorg.xf86inputjoystick ];
    };

    qt5.enable = true;
    qt5.platformTheme = "gtk2";
    qt5.style = "gtk2";

    # https://nixos.wiki/wiki/PipeWire#Low-latency_setup
    #services.pipewire = {
    #  config.pipewire = {
    #    "context.properties" = {
    #      "link.max-buffers" = 16;
    #      "log.level" = 2;
    #      "default.clock.rate" = 48000;
    #      "default.clock.quantum" = 32;
    #      "default.clock.min-quantum" = 32;
    #      "default.clock.max-quantum" = 32;
    #      "core.daemon" = true;
    #      "core.name" = "pipewire-0";
    #    };
    #    "context.modules" = [
    #      {
    #        name = "libpipewire-module-rtkit";
    #        args = {
    #          "nice.level" = -15;
    #          "rt.prio" = 88;
    #          "rt.time.soft" = 200000;
    #          "rt.time.hard" = 200000;
    #        };
    #        flags = [ "ifexists" "nofail" ];
    #      }
    #      { name = "libpipewire-module-protocol-native"; }
    #      { name = "libpipewire-module-profiler"; }
    #      { name = "libpipewire-module-metadata"; }
    #      { name = "libpipewire-module-spa-device-factory"; }
    #      { name = "libpipewire-module-spa-node-factory"; }
    #      { name = "libpipewire-module-client-node"; }
    #      { name = "libpipewire-module-client-device"; }
    #      {
    #        name = "libpipewire-module-portal";
    #        flags = [ "ifexists" "nofail" ];
    #      }
    #      {
    #        name = "libpipewire-module-access";
    #        args = {};
    #      }
    #      { name = "libpipewire-module-adapter"; }
    #      { name = "libpipewire-module-link-factory"; }
    #      { name = "libpipewire-module-session-manager"; }
    #    ];
    #  };
    #};
  };
}
