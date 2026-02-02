# flake-parts module
{ inputs, ... }:
let
  # Define services module inline to avoid self-reference
  servicesModule.imports = [
    ./services/forgejo.nix
    ./services/harmonia.nix
    ./services/mail-relay.nix
    ./services/searx.nix
    ./services/smokeping.nix
    ./services/docker.nix
    ./services/syncthing.nix
    ./services/vaultwarden.nix
  ];

  # Define individual window manager modules
  hyprlandModule.imports = [ ./window-managers/hyprland.nix ];
  i3Module.imports = [ ./window-managers/i3.nix ];
  niriModule.imports = [ ./window-managers/niri.nix ];
  swayModule.imports = [ ./window-managers/sway.nix ];

  # Define component modules
  commonModule.imports = [
    ./bluetooth
    ./browsers
    ./dnsmasq
    ./../../insecure-packages.nix
    ./solo2
    ./yubikey
    ./../../nixos-secrets.nix
  ];

  gumdropModule.imports = [ ./gumdrop ];

  linuxModule.imports = [
    ./boot-tor-service
    #./autologin-tty1
    ./hydra/builder.nix
    ./k3s
    ./machine
    ./media
    servicesModule
  ];

  tuiModule.imports = [
    ./tui.nix
    ./tmux.nix
    ./zsh
  ];

  guiModule.imports = [
    inputs.stylix.nixosModules.stylix
    ./stylix.nix
    ./control-monitor-backlight.nix
    ./plymouth-stylix-bg.nix
  ];
in
{
  flake = {
    nixosModules = {
      # For modules that work on both Linux and Darwin
      common = commonModule;

      gumdrop = gumdropModule;
      gumdropServer.import = [ ];
      #timberlake.imports = [ ./timberlake ];

      linux = linuxModule;

      server.imports = [
        inputs.NixVirt.nixosModules.default
        ./home-assistant
        ./hydra
        ./nextcloud
        ./postgres
        ./unattended
        servicesModule
      ];

      services = servicesModule;

      radio.imports = [
        ./sdr
      ];

      tui = tuiModule;

      gui = guiModule;

      gaming.imports = [
        ./steam
        ./gaming
      ];

      crypto.imports = [ ./crypto.nix ];

      work.imports = [ ./obsidian.nix ];

      hyprland = hyprlandModule;
      i3 = i3Module;
      niri = niriModule;
      sway = swayModule;

      windowManagers.imports = [
        hyprlandModule
        #i3Module
        niriModule
        swayModule
      ];

      #darwin.imports = [];

      default.imports = [
        commonModule
        linuxModule
        tuiModule
        guiModule
        gumdropModule
      ];
    };
  };
}
