{
  description = "GoldenBoy - Always there when you need him!";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.11;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixos-unstable;
    # explore prebuilt unfree packages
    #nixpkgs-unfree.url = github:numtide/nixos-unfree;

    # Nix User Repository: User contributed nix packages
    nur.url = github:nix-community/NUR;

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

    # Take NixOS configuration, and generate outputs for different target formats
    nixos-generators = {
      url = github:nix-community/nixos-generators;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Takes the NixOS module system and makes it work for disk partitioning as well
    disko = {
      #url = github:nix-community/disko;
      url = "/home/lriutzel/Projects/nix/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Run unpatched dynamic binaries on NixOS
    nix-ld = {
      url = github:Mic92/nix-ld;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fuse filesystem that returns symlinks to executables based on the PATH of
    # the requesting process. This is useful to execute shebangs on NixOS that
    # assume hard coded locations in locations like /bin or /usr/bin etc.
    envfs = {
      url = github:Mic92/envfs;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets.url = "/home/lriutzel/Projects/secrets";
  };

  outputs = {self, ...} @ inputs: let
    inherit (inputs.nixpkgs.lib) mapAttrs;
    inherit (inputs.flake-utils.lib) eachSystem flattenTree mkApp;
    defaultPkgs = inputs.nixpkgs;

    selfLib = import ./lib/default.nix {
      lib = defaultPkgs.lib;
      inherit inputs;
    };
    inherit (selfLib) importDirOfOverlays mkNixosSystem mkNixosSystemGenerator;

    supportedX86Systems = [
      "i686-linux"
      "x86_64-linux"
    ];

    supportedSystems =
      supportedX86Systems
      ++ [
        "aarch64-linux"
      ];

    #forAllSystems = nixlib.genAttrs supportedSystems;

    getCfg = _: cfg: cfg.config.system.build.toplevel;
  in
    {
      # Expose overlay to flake outputs, to allow using it from other flakes.
      overlays = importDirOfOverlays "overlays";

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = {
        reg = mkNixosSystem defaultPkgs "x86_64-linux" "reg";
        riko = mkNixosSystem defaultPkgs "x86_64-linux" "riko";

        marulk = mkNixosSystem defaultPkgs "x86_64-linux" "marulk";
        lyza = mkNixosSystem defaultPkgs "x86_64-linux" "lyza";
        nat = mkNixosSystem defaultPkgs "x86_64-linux" "nat";

        minimal = mkNixosSystem defaultPkgs "x86_64-linux" "minimal";
      };

      #hydraJobs = mapAttrs getCfg self.nixosConfiguratons;
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
      };

      apps = {
        winbox = mkApp {drv = packages.winbox;};
      };
    })
    // {
      packages.x86_64-linux.sd-image = mkNixosSystemGenerator defaultPkgs "x86_64-linux" "lyza";
      formatter.x86_64-linux = defaultPkgs.legacyPackages.x86_64-linux.alejandra;
    };

  nixConfig = {
    extra-substituters = "https://aseipp-nix-cache.global.ssl.fastly.net";
    #extra-trusted-public-keys
  };
}
