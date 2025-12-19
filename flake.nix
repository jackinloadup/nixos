{
  # TODO add treefmt, darwin
  description = "GoldenBoy - Always there when you need him!";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";
    #nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    ragenix.url = "github:yaxitech/ragenix";

    #nix-software-center = {
    #  url = "github:snowfallorg/nix-software-center";
    #  inputs.nixpkgs.follows = "nixpkgs-stable";
    #  #inputs.nixos-appstream-data.inputs.nixpkgs.follows = "nixpkgs";
    #  #inputs.nixos-appstream-data.inputs.flake-utils.follows = "flake-utils";
    #};

    # explore prebuilt unfree packages
    #nixpkgs-unfree.url = "github:numtide/nixos-unfree";

    nix-inspect.url = "github:bluskript/nix-inspect";

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

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
      url = "github:nix-community/home-manager/release-25.11";
      #url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # color library for theming
    base16 = {
      url = "github:alukardbf/base16-nix"; # defunk
      #url = "github:SenchoPens/base16.nix"; # look into?
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils-plus.follows = "flake-utils-plus";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      #url = "github:nix-community/stylix"; # unstable
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:nix-community/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-unified.url = "github:srid/nixos-unified";

    scripts = {
      url = "github:jackinloadup/scripts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixvim = {
      #url = "github:nix-community/nixvim/main";
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Devshell
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # AMD microcode updates
    #
    # AMD only provides microcodes to linux-firmware for certain server-grade
    # CPUs. For consumer CPUs, updates are distributed through BIOS releases by
    # motherboard and laptop manufacturers, which can be inconsistent, delayed,
    # or even discontinued over time. This flake ensures you have the latest
    # microcodes directly on NixOS, without depending on BIOS updates.
    ucodenix.url = "github:e-tho/ucodenix";

    # NixVirt lets you declare virtual machines
    #nixvirt.url = "AshleyYakeley/NixVirt";

    # Exploring the integration between Nix and AI coding agents
    #nix-ai-tools.url = "github:numtide/nix-ai-tools";

    affinity.url = "github:mrshmllow/affinity-nix";
    niri.url = "github:sodiboo/niri-flake";
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
          flake = self;
          inherit inputs;
        };
        inherit (selfLib) importDirOfOverlays allNixosSystems mkNixosSystemGenerator;

        supportedX86Systems = [ "i686-linux" "x86_64-linux" ];
        supportedSystems = supportedX86Systems ++ [ "aarch64-linux" ];
      in
        {
          # Expose overlay to flake outputs, to allow using it from other flakes.
          overlays = importDirOfOverlays "overlays";

          # Each subdirectory in ./machines is a host. Add them all to
          # nixosConfiguratons. Host configurations need a file called
          # configuration.nix that will be read first
          nixosConfigurations = allNixosSystems;

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
          pkgs = import defaultPkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in {
          devShells = flattenTree {
            rust = import ./shells/rust.nix {inherit pkgs;};
            hack = import ./shells/hack.nix {inherit pkgs;};
            secrets = import ./shells/secrets.nix {inherit pkgs;};
          };
        })
        // (eachSystem supportedX86Systems)
        (system: let
          pkgs = defaultPkgs.legacyPackages.${system}.extend self.overlays.default;
        in rec {
          # Custom packages added via the overlay are selectively added here, to
          # allow using them from other flakes that import this one.
          packages = flattenTree {
            rtl_433-dev = pkgs.rtl_433-dev;
            ragenix = inputs.ragenix.packages.${system}.default;
          };

          apps = {
            rtl_433-dev = mkApp {drv = packages.rtl_433-dev;};
          };
        })
        // {
          packages.x86_64-linux.iso-image = mkNixosSystemGenerator defaultPkgs "x86_64-linux" "lyza";
          #packages.x86_64-linux.iso-image = mkNixosSystemGenerator defaultPkgs "x86_64-linux" "zen";
          templates = {
            machine = {
              path = ./templates/machine;
              description = "File structure for a new machines";
            };
            shell = {
              path = ./templates/shell;
              description = "A nix shell using direnv to autoload on entry";
            };
          };
        };

      perSystem = { self', system, pkgs, lib, config, inputs', ... }: let
          nixvimLib = inputs.nixvim.lib.${system};
          nixvimPkgs = inputs.nixvim.legacyPackages.${system};
          nixvimBasicModule = {
            inherit system pkgs;
            module = import ./modules/nixvim/basic.nix;
          };
          nixvimFullModule = {
            inherit system pkgs;
            module = import ./modules/nixvim/full.nix;
          };
          nvimBasic = nixvimPkgs.makeNixvimWithModule nixvimBasicModule;
          nvimFull = nixvimPkgs.makeNixvimWithModule nixvimFullModule;
      in {
        nixos-unified.primary-inputs = [ "nixpkgs" "home-manager" "nix-darwin" "nixos-unified" ];

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
          #formatter.x86_64-linux = defaultPkgs.legacyPackages.x86_64-linux.alejandra;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = with self.outputs.devShells.${system}; [ secrets ];
          buildInputs = [
            pkgs.nixpkgs-fmt
            #pkgs.sops
            #pkgs.ssh-to-age
          ];
          packages = [
            #pkgs.
          ];
        };

        formatter = config.treefmt.build.wrapper;

        checks = {
          # Run `nix flake check .` to verify that your config is not broken
          nvimBasic = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimBasicModule;
          nvimFull = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimFullModule;
        };

        packages = {
          nvimBasic = nvimBasic;
          nvimFull = nvimFull;
        };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://aseipp-nix-cache.global.ssl.fastly.net"
      "https://niri.cachix.org"
    ];
  };
}
