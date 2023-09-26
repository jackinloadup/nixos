{
  # TODO add treefmt, darwin
  description = "GoldenBoy - Always there when you need him!";

  inputs = {
    #nixpkgs.url = github:nixos/nixpkgs/nixos-23.05;
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixos-unstable;
    # explore prebuilt unfree packages
    #nixpkgs-unfree.url = github:numtide/nixos-unfree;

    # Nix User Repository: User contributed nix packages
    nur.url = github:nix-community/NUR;

    # Simplify Nix Flakes with the module system
    flake-parts.url = github:hercules-ci/flake-parts;

    # Pure Nix flake utility functions
    flake-utils.url = github:numtide/flake-utils;

    # Use Nix flakes without any fluff
    flake-utils-plus = {
      url = github:gytis-ivaskevicius/flake-utils-plus;
      inputs.flake-utils.follows = "flake-utils";
    };

    # A collection of NixOS modules covering hardware quirks
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    # Modules to help handle persistent state on systems with ephemeral root storage
    impermanence.url = github:nix-community/impermanence;

    # Manage a user environment using Nix
    home-manager = {
      #url = github:nix-community/home-manager/release-23.05;
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # color library for theming
    base16 = {
      url = github:alukardbf/base16-nix;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-plus.follows = "flake-utils-plus";
    };

    # Take NixOS configuration, and generate outputs for different target formats
    nixos-generators = {
      url = github:nix-community/nixos-generators;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Takes the NixOS module system and makes it work for disk partitioning as well
    disko = {
      url = github:nix-community/disko;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixd.url = github:nix-community/nixd;

    # Run unpatched dynamic binaries on NixOS
    nix-ld = {
      url = github:Mic92/nix-ld;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = github:Mic92/nix-index-database;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-flake.url = github:srid/nixos-flake;

    # Fuse filesystem that returns symlinks to executables based on the PATH of
    # the requesting process. This is useful to execute shebangs on NixOS that
    # assume hard coded locations in locations like /bin or /usr/bin etc.
    envfs = {
      url = github:Mic92/envfs;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "/home/lriutzel/Projects/secrets";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    scripts = {
      url = "/home/lriutzel/Projects/scripts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixvim.url = github:pta2002/nixvim;

    # Devshell
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {self, ...} @ inputs: 
    inputs.flake-parts.lib.mkFlake {inherit inputs; } {
      systems = [
        #"i686-linux"
        "x86_64-linux"
        #"aarch64-linux"
      ];
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nixos-flake.flakeModule
        ./modules/nixos
        ./modules/home-manager
        ./users
      ];
      flake = let
        inherit (inputs.nixpkgs.lib) mapAttrs;
        inherit (inputs.flake-utils.lib) eachDefaultSystem eachSystem flattenTree mkApp;
        defaultPkgs = inputs.nixpkgs;

        selfLib = import ./lib/default.nix {
          lib = defaultPkgs.lib;
          inherit inputs;
        };
        inherit (selfLib) importDirOfOverlays importDirOfModules mkNixosSystem mkNixosSystemGenerator;

        supportedX86Systems = [
          "i686-linux"
          "x86_64-linux"
        ];

        supportedSystems =
          supportedX86Systems
          ++ [
            "aarch64-linux"
          ];
      in
        {
          # Expose overlay to flake outputs, to allow using it from other flakes.
          overlays = importDirOfOverlays "overlays";

          # Each subdirectory in ./machines is a host. Add them all to
          # nixosConfiguratons. Host configurations need a file called
          # configuration.nix that will be read first
          nixosConfigurations = {
            reg = self.nixos-flake.lib.mkLinuxSystem {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                ./machines/reg/configuration.nix
              ];
            };
            riko = self.nixos-flake.lib.mkLinuxSystem {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                ./machines/riko/configuration.nix
              ];
            };
            #reg = mkNixosSystem defaultPkgs "x86_64-linux" "reg";
            #riko = mkNixosSystem inputs.nixpkgs-unstable "x86_64-linux" "riko";

            marulk = mkNixosSystem defaultPkgs "x86_64-linux" "marulk";
            lyza = mkNixosSystem defaultPkgs "x86_64-linux" "lyza";
            nat = mkNixosSystem defaultPkgs "x86_64-linux" "nat";

            minimal = mkNixosSystem defaultPkgs "x86_64-linux" "minimal";
          };

          #nixosModules = importDirOfModules "modules/nixos";
          #homeManagerModules = importDirOfModules "modules/home-manager";

          #homeConfigurations = {
          #  lriutzel = inputs.home-manager.lib.homeManagerConfiguration {
          #    pkgs = defaultPkgs;
          #    modules = [
          #    ];
          #  };
          #};

        }
        // (eachSystem supportedSystems)
        (system: let
          pkgs = defaultPkgs.legacyPackages.${system}.extend self.overlays.default;
        in rec {
          devShells = flattenTree {
            rust = import ./shells/rust.nix {inherit pkgs;};
          };
        })
        // (eachSystem supportedX86Systems)
        (system: let
          pkgs = defaultPkgs.legacyPackages.${system}.extend self.overlays.default;
        in rec {
          # Custom packages added via the overlay are selectively added here, to
          # allow using them from other flakes that import this one.
          packages = flattenTree {
            winbox = pkgs.wineApps.winbox;
            rtl_433-dev = pkgs.rtl_433-dev;
          };

          apps = {
            winbox = mkApp {drv = packages.winbox;};
            rtl_433-dev = mkApp {drv = packages.rtl_433-dev;};
          };
        })
        // {
          #packages.x86_64-linux.sd-image = mkNixosSystemGenerator defaultPkgs "x86_64-linux" "lyza";
          templates = {
            shell = {
              path = ./templates/shell;
              description = "A nix shell using direnv to autoload on entry";
            };
          };
        };

      perSystem = { self', system, pkgs, lib, config, inputs', ... }: {
        nixos-flake.primary-inputs = [ "nixpkgs" "home-manager" "nix-darwin" "nixos-flake" ];

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
          #formatter.x86_64-linux = defaultPkgs.legacyPackages.x86_64-linux.alejandra;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nixpkgs-fmt
            #pkgs.sops
            #pkgs.ssh-to-age
          ];
        };

        formatter = config.treefmt.build.wrapper;
      };
    };

  nixConfig = {
    extra-substituters = "https://aseipp-nix-cache.global.ssl.fastly.net";
  };
}
