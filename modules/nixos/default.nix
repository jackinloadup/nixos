# flake-parts module
{ self, inputs, ... }:
{
  flake = {
    nixosModules = {
      # For modules that work on both Linux and Darwin
      common.imports = [
        #./arewehackersyet
        ./bluetooth
        ./browsers
        ./dnsmasq
        ./gumdrop
        ./../../insecure-packages.nix
        ./solo2
        ./unattended
        ./yubikey
        ./zsh
        ./../../nixos-secrets.nix
      ];

      linux.imports = [
        ./boot-tor-service
        #./autologin-tty1
        ./machine
        ./home-assistant
        ./k3s
        ./machine
        ./nextcloud
        ./media
      ];

      server.imports = [
        ./hydra
        ./postgres
      ];

      radio.imports = [
        ./sdr
        ./rtl_433
      ];

      tui.imports = [

      ];

      gui.imports = [
        inputs.stylix.nixosModules.stylix
        inputs.niri.nixosModules.niri
        ./steam
        ./gaming
        ./control-monitor-backlight.nix
      ];

      crypto.imports = [
        ./crypto.nix
      ];

      work.imports = [
        ./obsidian.nix
      ];

      #darwin.imports = [
      #];

      #my-home = {
      #  users.users.${config.people.myself}.isNormalUser = true;
      #  home-manager.users.${config.people.myself} = {
      #    imports = [
      #      self.homeModules.common-linux
      #    ];
      #  };
      #};

      default.imports = [
        inputs.self.nixosModules.common
        inputs.self.nixosModules.linux
        #inputs.self.nixosModules.home-manager
        inputs.self.nixosModules.tui
        inputs.self.nixosModules.gui
        #self.nixosModules.my-home
        #./self-ide.nix
        #./ssh-authorize.nix
        #./current-location.nix
      ];
    };
  };
}
