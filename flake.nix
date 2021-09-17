{
  description = "My machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # color library for theming
    base16.url = "github:montchr/base16-nix";

    # nix-hardware.url = github:NixOS/nixos-hardware/master;
    #nur = { url = "github:nix-community/NUR"; };
    secrets.url = "/home/lriutzel/Projects/secrets";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, secrets, ... }:
  {
    nixosConfigurations = {
      nixpad = with nixpkgs.lib;
        let
          system = "x86_64-linux";
          modules = [
            ./machines/nixpad.nix
            home-manager.nixosModules.home-manager
            secrets.nixosModules.default
            {
              nix.registry.nixpkgs.flake = nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.users.lriutzel = import ./home;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            #(./. + "/hosts/${hostname}/configuration.nix")
          ];
          specialArgs = { inherit inputs; };
        in nixosSystem { inherit system modules specialArgs; };
    };
  };
}

