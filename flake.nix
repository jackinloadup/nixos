{
  # TODO add treefmt, darwin
  description = "GoldenBoy - Always there when you need him!";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    nix-software-center = {
      url = "github:snowfallorg/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.nixos-appstream-data.inputs.nixpkgs.follows = "nixpkgs";
      #inputs.nixos-appstream-data.inputs.flake-utils.follows = "flake-utils";

    };

    # explore prebuilt unfree packages
    #nixpkgs-unfree.url = "github:numtide/nixos-unfree";

    nix-inspect.url = "github:bluskript/nix-inspect";


    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Nix User Repository: User contributed nix packages
    nur.url = "github:nix-community/NUR";

    # Simplify Nix Flakes with the module system
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Pure Nix flake utility functions
    flake-utils.url = "github:numtide/flake-utils";

    # Use Nix flakes without any fluff
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    # A collection of NixOS modules covering hardware quirks
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Modules to help handle persistent state on systems with ephemeral root storage
    impermanence.url = "github:nix-community/impermanence";

    # Manage a user environment using Nix
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      #url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # color library for theming
    base16 = {
      url = "github:alukardbf/base16-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-plus.follows = "flake-utils-plus";
    };

    # Take NixOS configuration, and generate outputs for different target formats
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Takes the NixOS module system and makes it work for disk partitioning as well
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nixd.url = "github:nix-community/nixd";

    # Run unpatched dynamic binaries on NixOS
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-unified.url = "github:srid/nixos-unified";

    # Fuse filesystem that returns symlinks to executables based on the PATH of
    # the requesting process. This is useful to execute shebangs on NixOS that
    # assume hard coded locations in locations like /bin or /usr/bin etc.
    envfs = {
      url = "github:Mic92/envfs";
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

    nixvim = {
      #url = "github:nix-community/nixvim/main";
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
        inputs.nixos-unified.flakeModule
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
            # Personal Desktop
            reg = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                ./machines/reg/configuration.nix
              ];
            };
            # Wife Desktop
            zen = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                self.nixosModules.criutzel
                ./machines/zen/configuration.nix
              ];
            };
            # Personal laptop
            riko = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                self.nixosModules.criutzel
                ./machines/riko/configuration.nix
              ];
            };
            # TV box
            nat = self.nixos-unified.lib.mkLinuxSystem  { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                self.nixosModules.kodi
                ./machines/nat/configuration.nix
              ];
            };
            # home server
            marulk = self.nixos-unified.lib.mkLinuxSystem  { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                ./machines/marulk/configuration.nix
              ];
            };
            # Server at studio location
            lyza = self.nixos-unified.lib.mkLinuxSystem  { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                ./machines/lyza/configuration.nix
              ];
            };
            # Christine newer laptop
            kanye = self.nixos-unified.lib.mkLinuxSystem  { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                self.nixosModules.criutzel
                ./machines/kanye/configuration.nix
              ];
            };
            # Christine micro server
            jesus = self.nixos-unified.lib.mkLinuxSystem  { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                self.nixosModules.criutzel
                ./machines/jesus/configuration.nix
              ];
            };
            # Server at timberlake location
            timberlake = self.nixos-unified.lib.mkLinuxSystem  { home-manager = true; } {
              imports = [
                self.nixosModules.default
                self.nixosModules.lriutzel
                ./machines/timberlake/configuration.nix
              ];
            };
            minimal = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
              imports = [
                self.nixosModules.default
                ./machines/minimal/configuration.nix
              ];
            };
            #reg = mkNixosSystem defaultPkgs "x86_64-linux" "reg";
            #riko = mkNixosSystem inputs.nixpkgs-unstable "x86_64-linux" "riko";
            #nat = mkNixosSystem defaultPkgs "x86_64-linux" "nat";
            #marulk = mkNixosSystem defaultPkgs "x86_64-linux" "marulk";
            #lyza = mkNixosSystem defaultPkgs "x86_64-linux" "lyza";
            #minimal = mkNixosSystem defaultPkgs "x86_64-linux" "minimal";
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
          packages.x86_64-linux.iso-image = mkNixosSystemGenerator defaultPkgs "x86_64-linux" "lyza";
          #packages.x86_64-linux.iso-image = mkNixosSystemGenerator defaultPkgs "x86_64-linux" "zen";
          templates = {
            shell = {
              path = ./templates/shell;
              description = "A nix shell using direnv to autoload on entry";
            };
          };
        };

      perSystem = { self', system, pkgs, lib, config, inputs', ... }: {
        nixos-unified.primary-inputs = [ "nixpkgs" "home-manager" "nix-darwin" "nixos-unified" ];

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
