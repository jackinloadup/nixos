{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkDefault mkForce;
  cfg = config.machine;
  settings = import ../../../settings;
in {
  imports = [
    ./openrct2.nix
  ];

  options.machine.gaming = mkEnableOption "Enable extra options only needed for gaming";

  config = mkIf cfg.gaming {
    programs.steam.enable = true;

    # Look into https://www.nyx.chaotic.cx/
    # yuzu-early-access_git  # experimental Nintendo Switch emulator
    networking.firewall.allowedTCPPorts = [
      #25565 # minecraft not all ports
    ];

    environment.systemPackages = with pkgs; [
      #monado
      #lighthouse-steamvr
      libgdiplus
      adwaita-icon-theme

      # SNES
      snes9x-gtk

      # xorg stuff
      xorg.xhost # for `xhost si:localuser:root`

      #nur.repos.dukzcry.gamescope
      #retroarch
      #retroarchFull
      prismlauncher # minecraft
      #supertuxkart # alt mario cart
      #warsow # Multiplayer FPS game
      #cool-retro-term
      gamehub
      nethack # Rogue-like game
      #mindustry
      gltron

      discord
      clonehero
    ];

    services.xserver = {
      modules = [pkgs.xorg.xf86inputjoystick];
    };

    qt.enable = mkDefault true;
    qt.platformTheme = mkDefault "gnome";
    qt.style = mkDefault "adwaita-dark";

    home-manager.sharedModules = [
      {
        qt.enable = mkForce true;
        qt.platformTheme.name = mkForce "adwaita";
        qt.style.name = mkForce "adwaita-dark";
        qt.style.package = mkForce pkgs.adwaita-qt;
      }
    ];

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
