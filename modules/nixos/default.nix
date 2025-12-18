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

      gumdrop.imports = [ ./gumdrop ];
      gumdropServer.import = [];
      #timberlake.imports = [ ./timberlake ];

      linux.imports = [
        ./boot-tor-service
        #./autologin-tty1
        ./k3s
        ./machine
        ./media
        inputs.self.nixosModules.services
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
        ./services/smokeping.nix
        ./services/docker.nix
        ./services/syncthing.nix
        ./services/vaultwarden.nix
      ];

      radio.imports = [
        ./sdr
      ];

      tui.imports = [
        ./tmux.nix
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
      i3.imports = [ ./window-managers/i3.nix ];
      niri.imports = [ ./window-managers/niri.nix ];
      sway.imports = [ ./window-managers/sway.nix ];

      windowManagers.imports = [
        inputs.self.nixosModules.hyprland
        #inputs.self.nixosModules.i3
        inputs.self.nixosModules.niri
        inputs.self.nixosModules.sway
      ];

      #darwin.imports = [];

      default.imports = [
        inputs.self.nixosModules.common
        inputs.self.nixosModules.linux
        inputs.self.nixosModules.tui
        inputs.self.nixosModules.gui
        inputs.self.nixosModules.gumdrop
      ];
    };
  };
}
