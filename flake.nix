{
  description = "My machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # color library for theming
    base16.url = "github:montchr/base16-nix";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    secrets.url = "/home/lriutzel/Projects/secrets";
  };

  outputs = { self, nixpkgs, nixos-hardware, secrets, ... }@inputs:
    with inputs;
    let
      # Function to create default (common) system config options
      defFlakeSystem = machineName: baseCfg:
        nixpkgs.lib.nixosSystem {

          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = 
          # This was how I figure out how to get nixos-hardware stuff working.
          # imports didn't work and README showed modules
          ( import (./machines + "/${machineName}/modules.nix") { nixos-hardware=nixos-hardware; } )
          ++ [
            ({ ... }: {
              imports = builtins.attrValues self.nixosModules ++ [
                {
                  # Set the $NIX_PATH entry for nixpkgs. This is necessary in
                  # this setup with flakes, otherwise commands like `nix-shell
                  # -p pkgs.htop` will keep using an old version of nixpkgs.
                  # With this entry in $NIX_PATH it is possible (and
                  # recommended) to remove the `nixos` channel for both users
                  # and root e.g. `nix-channel --remove nixos`. `nix-channel
                  # --list` should be empty for all users afterwards
                  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                  nixpkgs.overlays =
                    [ self.overlay nur.overlay ];

                  # DON'T set useGlobalPackages! It's not necessary in newer
                  # home-manager versions and does not work with configs using
                  # nixpkgs.config`
                  home-manager.useUserPackages = true;
                }
                secrets.nixosModules.default
                baseCfg
                home-manager.nixosModules.home-manager {
                  home-manager.users.lriutzel = import ./home ;
                  home-manager.extraSpecialArgs = { inherit inputs; };
                }

              ];

              # Let 'nixos-version --json' know the Git revision of this flake.
              system.configurationRevision =
                nixpkgs.lib.mkIf (self ? rev) self.rev;
              nix.registry.nixpkgs.flake = nixpkgs;
            })
          ];
        };
    in {

      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlay = final: prev: (import ./overlays inputs) final prev;

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs (map (x: {
        name = x;
        value = import (./modules + "/${x}");
      }) (builtins.attrNames (builtins.readDir  ./modules)));

      # Each subdirectory in ./machins is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs (map (x: {
        name = x;
        value = defFlakeSystem x {
          imports = [
            #(import (./machines + "/${x}/configuration.nix") { inherit self inputs pkgs; })
            (./machines + "/${x}/configuration.nix")
          ];
        };
      }) (builtins.attrNames (builtins.readDir ./machines)));
    };
    #} //

    # All packages in the ./packages subfolder are also added to the flake.
    # flake-utils is used for this part to make each package available for each
    # system. This works as all packages are compatible with all architectures
    #(flake-utils.lib.eachSystem [ "aarch64-linux" "i686-linux" "x86_64-linux" ])
    #(system:
    #  let pkgs = nixpkgs.legacyPackages.${system}.extend self.overlay;
    #  in rec {
    #    # Custom packages added via the overlay are selectively added here, to
    #    # allow using them from other flakes that import this one.
    #    packages = flake-utils.lib.flattenTree {
    #      wezterm-bin = pkgs.wezterm-bin;
    #      wezterm-nightly = pkgs.wezterm-nightly;
    #      hello-custom = pkgs.hello-custom;
    #      filebrowser = pkgs.filebrowser;
    #      darktile = pkgs.darktile;
    #      zk = pkgs.zk;
    #    };

    #    apps = {
    #      # Allow custom packages to be run using `nix run`
    #      hello-custom = flake-utils.lib.mkApp { drv = packages.hello-custom; };
    #      wezterm-bin = flake-utils.lib.mkApp {
    #        drv = packages.wezterm-bin;
    #        exePath = "/bin/wezterm";
    #      };
    #    };

    #    # TODO we probably should set some default app and/or package
    #    # defaultPackage = packages.hello;
    #    # defaultApp = apps.hello;
    #  });

  #outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
  #  nixosConfigurations = {
  #    nixpad = with nixpkgs.lib;
  #      let
  #        system = "x86_64-linux";
  #        modules = [
  #          ./machines/nixpad.nix
  #          home-manager.nixosModules.home-manager
  #          {
  #            nix.registry.nixpkgs.flake = nixpkgs;
  #            home-manager.useGlobalPkgs = true;
  #            home-manager.useUserPackages = false;
  #            home-manager.users.lriutzel = import ./home;
  #            home-manager.extraSpecialArgs = { inherit inputs; };
  #          }
  #          #(./. + "/hosts/${hostname}/configuration.nix")
  #        ];
  #        specialArgs = { inherit inputs; };
  #      in nixosSystem { inherit system modules specialArgs; };
  #  };
  #};
}

