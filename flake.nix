{
  description = "My machines";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-21.11;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-sway-17.url = github:nixos/nixpkgs?rev=0860d0db4f74770677011bf9c95a1d76b38ba512;

    flake-utils.url = github:numtide/flake-utils;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;

    # Manage a user environment using Nix
    home-manager = {
      url = github:nix-community/home-manager/release-21.05;
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
    secrets.url = "/home/lriutzel/Projects/secrets";
  };

  outputs = { self, nixpkgs, nixos-hardware, nixpkgs-unstable, secrets, ... }@inputs:
    with inputs;
    let
      defineModule = name: dir: {
        name = name;
        value = import (./. + ("/" + dir + "/" + name));
      };

      importModulesDir = dir: builtins.listToAttrs (
        map (name: defineModule name dir) (builtins.attrNames (builtins.readDir  (builtins.toPath  ./. + "/${dir}")))
      );

      # Output all modules in ./users to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosUsers = importModulesDir "users";

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
              imports = builtins.attrValues self.nixosModules
              ++ builtins.attrValues nixosUsers
              ++ [
                {
                  # Set the $NIX_PATH entry for nixpkgs. This is necessary in
                  # this setup with flakes, otherwise commands like `nix-shell
                  # -p pkgs.htop` will keep using an old version of nixpkgs.
                  # With this entry in $NIX_PATH it is possible (and
                  # recommended) to remove the `nixos` channel for both users
                  # and root e.g. `nix-channel --remove nixos`. `nix-channel
                  # --list` should be empty for all users afterwards
                  #nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                  nix.nixPath = let path = toString ./.; in [
                    "repl=${path}/repl.nix"
                    "nixpkgs=${nixpkgs}"
                  ];

                  nixpkgs.overlays = [
                    self.overlay
                    nur.overlay
                  ];
                }
                secrets.nixosModules.default
                baseCfg
              ];

              nix.registry.nixpkgs.flake = nixpkgs;

              # Let 'nixos-version --json' know the Git revision of this flake.
              system.configurationRevision =
                nixpkgs.lib.mkIf (self ? rev) self.rev;
            })
          ];
        };
    in {
      # Allow unfree packages.
      nixpkgs.config.allowUnfree = true;

      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlay = final: prev: (import ./overlays inputs) final prev;

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = importModulesDir "modules";

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs (map (x: {
        name = x;
        value = defFlakeSystem x {
          imports = [
            #(import (./machines + "/${x}/configuration.nix") { inherit self inputs pkgs; })
            (./machines + "/${x}/configuration.nix")
          ];

          # allow modules to use inputs in addition to their normal args
          _module.args.inputs = inputs;
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
}

