{
  description = "GoldenBoy - Always there when you need him!";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.11;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixos-unstable;

    flake-utils.url = github:numtide/flake-utils;
    flake-utils-plus = {
      url = github:gytis-ivaskevicius/flake-utils-plus;
      inputs.flake-utils.follows = "flake-utils";
    };

    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    # Manage a user environment using Nix
    home-manager = {
      url = github:nix-community/home-manager/release-22.11;
      #url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    # color library for theming
    base16 = {
      url = github:alukardbf/base16-nix;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-plus.follows = "flake-utils-plus";
    };

    # NUR is a registry of Nix User Repositories
    nur = {
      url = github:nix-community/NUR;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modules to help you handle persistent state on systems with ephemeral root storage.
    impermanence.url = github:nix-community/impermanence;

    # Takes the NixOS module system and makes it work for disk partitioning as well
    disko = {
      #url = github:nix-community/disko;
      url = "/home/lriutzel/Projects/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets.url = "/home/lriutzel/Projects/secrets";
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      inherit (flake-utils.lib) eachSystem flattenTree mkApp;

      supportedX86Systems = [
        "i686-linux"
        "x86_64-linux"
      ];

      supportedSystems = supportedX86Systems ++ [
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

    (eachSystem supportedSystems)
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
      in rec {
        devShells = flattenTree {
          rust = import ./shells/rust.nix { pkgs = pkgs; };
        };
      }) //

    (eachSystem supportedX86Systems)
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
      in rec {
        # Custom packages added via the overlay are selectively added here, to
        # allow using them from other flakes that import this one.
        packages = flattenTree {
          winbox = pkgs.wineApps.winbox;
        };

        apps = {
          winbox = mkApp { drv = packages.winbox; };
        };
      });
  nixConfig = {
    substituters = "https://aseipp-nix-cache.global.ssl.fastly.net";
  };
}
