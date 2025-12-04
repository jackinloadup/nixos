# flake-parts module
{ self, inputs, ... }:
{
  flake = {
    nixosModules = {
      # For modules that work on both Linux and Darwin
      common.imports = [
        ./bluetooth
        ./browsers
        ./dnsmasq
        ./../../insecure-packages.nix
        ./solo2
        ./yubikey
        ./../../nixos-secrets.nix
      ];

      home.imports = [
        ./gumdrop
      ];

      linux.imports = [
        ./boot-tor-service
        #./autologin-tty1
        ./machine
        ./k3s
        ./machine
        ./media
      ];

      server.imports = [
        ./home-assistant
        ./hydra
        ./nextcloud
        ./postgres
        ./unattended
        inputs.self.nixosModules.services
      ];

      services.imports = [
        ./services/searx.nix
      ];

      radio.imports = [
        ./sdr
      ];

      tui.imports = [
        ./zsh
      ];

      gui.imports = [
        inputs.stylix.nixosModules.stylix
        ./control-monitor-backlight.nix
      ];

      gaming.imports = [
        ./steam
        ./gaming
      ];

      crypto.imports = [ ./crypto.nix ];

      work.imports = [ ./obsidian.nix ];

      hyprland.imports = [ ./window-managers/hyprland.nix ];
      niri.imports = [ ./window-managers/niri.nix ];

      windowManagers.imports = [
        inputs.self.nixosModules.hyprland
        inputs.self.nixosModules.niri
      ];

      #darwin.imports = [];

      default.imports = [
        inputs.self.nixosModules.common
        inputs.self.nixosModules.linux
        inputs.self.nixosModules.tui
        inputs.self.nixosModules.gui
        inputs.self.nixosModules.home
      ];
    };
  };
}
