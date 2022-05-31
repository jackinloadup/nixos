{
  description = "GoldenBoy - Always there when you need him!";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.05;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixos-unstable;

    flake-utils.url = github:numtide/flake-utils;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    # Manage a user environment using Nix
    home-manager = {
      #url = github:nix-community/home-manager/release-21.11;
      #inputs.nixpkgs.follows = "nixpkgs";
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # color library for theming
    base16 = {
      url = github:montchr/base16-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NUR is a registry of Nix User Repositories
    nur = {
      url = github:nix-community/NUR;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modules to help you handle persistent state on systems with ephemeral root storage.
    impermanence = {
      url = github:nix-community/impermanence;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets.url = "/home/lriutzel/Projects/secrets";
  };

  outputs = { self, nixpkgs, nixos-hardware, nixpkgs-unstable, secrets, impermanence, ... }@inputs:
    with inputs;
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      #forAllSystems = nixlib.genAttrs supportedSystems;

      defaultPkgs = nixpkgs;
      inherit ( import ./lib/default.nix { lib = defaultPkgs.lib; inherit inputs; }) importModulesDir mkNixosSystem;
    in {
      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlay = final: prev: (import ./overlays inputs) final prev;

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = {
        reg = mkNixosSystem inputs.nixpkgs "x86_64-linux" "reg";
        riko = mkNixosSystem inputs.nixpkgs "x86_64-linux" "riko";
        marulk = mkNixosSystem inputs.nixpkgs "x86_64-linux" "marulk";
        nat = mkNixosSystem inputs.nixpkgs "x86_64-linux" "nat";
      };
    } //

    # flake-utils is used for this part to make each package available for each
    # system. This works as all packages are compatible with all architectures
    #(flake-utils.lib.eachSystem [ "aarch64-linux" "i686-linux" "x86_64-linux" ])
    (flake-utils.lib.eachSystem [ "x86_64-linux" ])
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}.extend self.overlay;
      in rec {
        # Custom packages added via the overlay are selectively added here, to
        # allow using them from other flakes that import this one.
        packages = flake-utils.lib.flattenTree {
          winbox = pkgs.wineApps.winbox;
        };

        apps = {
          winbox = flake-utils.lib.mkApp { drv = packages.winbox; };
        };

        # TODO we probably should set some default app and/or package
        # defaultPackage = packages.hello;
        # defaultApp = apps.hello;
      });
}
