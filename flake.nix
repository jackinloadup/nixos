{
  description = "GoldenBoy - Always there when you need him!";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.05;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixos-unstable;

    flake-utils.url = github:numtide/flake-utils;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    # Manage a user environment using Nix
    home-manager = {
      url = github:nix-community/home-manager/release-22.05;
      #url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # color library for theming
    base16 = {
      url = github:alukardbf/base16-nix;
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
      inherit ( import ./lib/default.nix { lib = defaultPkgs.lib; inherit inputs; }) importDirOfOverlays mkNixosSystem;
    in {
      # Expose overlay to flake outputs, to allow using it from other flakes.
      overlays = importDirOfOverlays "overlays";

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = {
        reg = mkNixosSystem inputs.nixpkgs "x86_64-linux" "reg";
        riko = mkNixosSystem inputs.nixpkgs "x86_64-linux" "riko";
        marulk = mkNixosSystem inputs.nixpkgs "x86_64-linux" "marulk";
        nat = mkNixosSystem inputs.nixpkgs "x86_64-linux" "nat";
        minimal = mkNixosSystem inputs.nixpkgs "x86_64-linux" "minimal";
      };
    } //

    (flake-utils.lib.eachSystem [ "aarch64-linux" "i686-linux" "x86_64-linux" ])
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
      in rec {
        devShells = flake-utils.lib.flattenTree {
          rust = import ./shells/rust.nix { pkgs = pkgs; };
        };
      }) //

    (flake-utils.lib.eachSystem [ "x86_64-linux" "i686-linux" ])
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
      in rec {
        # Custom packages added via the overlay are selectively added here, to
        # allow using them from other flakes that import this one.
        packages = flake-utils.lib.flattenTree {
          winbox = pkgs.wineApps.winbox;
        };

        apps = {
          winbox = flake-utils.lib.mkApp { drv = packages.winbox; };
        };
      });
}
