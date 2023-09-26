# flake-parts module
{ self, inputs, ... }:
{
  flake = {
    nixosModules = {
      # For modules that work on both Linux and Darwin
      common.imports = [
        inputs.secrets.nixosModules.default
        #./arewehackersyet
        ./bluetooth
        ./botamusique
        ./browsers
        ./dnsmasq
        ./gaming
        ./gumdrop
        ./postgres
        ./solo2
        ./steam
        ./theme
        ./unattended
        ./vault
        ./yubikey
        ./zsh
      ];

      linux.imports = [
        ./boot-tor-service
        ./autologin-tty1
        ./machine
        ./hydra
        ./home-assistant
        ./k3s
        ./machine
        ./sdr
        ./rtl_433
        ./simula
        ./nextcloud
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
        inputs.self.nixosModules.home-manager
        #self.nixosModules.my-home
        #./self-ide.nix
        #./ssh-authorize.nix
        #./current-location.nix
      ];
    };
  };
}
