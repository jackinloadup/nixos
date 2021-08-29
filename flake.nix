{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-hardware.url = github:NixOS/nixos-hardware/master;
    #nur = { url = "github:nix-community/NUR"; };
    secrets.url = "/home/lriutzel/Projects/secrets";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, secrets, ... }:
  {
    nixosConfigurations = {

      nixpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/nixpad.nix
          home-manager.nixosModules.home-manager
          secrets.nixosModules.default
          {
            #nix.registry.nixpkgs.flake = nixpkgs;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.lriutzel = import ./home;
          }
          #(./. + "/hosts/${hostName}/configuration.nix")
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}

