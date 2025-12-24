{ lib
, inputs
, flake
, ...
}:
let
  inherit
    (builtins)
    attrNames
    attrValues
    pathExists
    readDir
    toPath
    listToAttrs
    filter
    ;
  inherit
    (lib)
    genAttrs
    mapAttrs'
    nameValuePair
    mapAttrs
    mapAttrsToList
    forEach
    mkForce
    ;
  inherit (lib.strings) removeSuffix;
  inherit (inputs) nixos-generators;

  rootPath = ../.;
  buildPath = dir: name: (rootPath + "/${dir}/${name}");
  importOverlaySet = name: path: {
    name = removeSuffix ".nix" name;
    value = importOverlay path flake;
  };
  importModuleSet = name: path: {
    name = removeSuffix ".nix" name;
    value = import path;
  };
  importOverlay = path: args: (final: prev: (import path args) final prev);
  filesInDir = dir: attrNames (readDir (toPath rootPath + "/${dir}"));

  specialArgs = { flake = { inherit inputs; }; };
in
rec {
  importDirOfOverlays = dir:
    listToAttrs (
      map (name: importOverlaySet name (buildPath dir name)) (filesInDir dir)
    );
  importDirOfModules = dir:
    listToAttrs (
      map (name: importModuleSet name (buildPath dir name)) (filesInDir dir)
    );
  nixosModules = importDirOfModules "modules/nixos";
  nixosUsers = importDirOfModules "users";

  machines = attrNames (readDir (rootPath + "/machines"));
  machinesHasConfig = (host: pathExists (rootPath + "/machines/${host}/configuration.nix"));
  machinesWithConfig = filter (host: machinesHasConfig host) machines;

  allNixosSystems = genAttrs machinesWithConfig mkNixosSystem;

  mkNixosSystem = (name:
    let
      flakeArg = { inherit inputs; self = inputs.self; };
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; inherit (inputs) self; flake = flakeArg; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; flake = flakeArg; };
          home-manager.useGlobalPkgs = true;
        }
        (rootPath + "/machines/${name}/configuration.nix")
      ];
    }
  );

  mkNixosSystemGenerator = pkgs: system: hostname:
    nixos-generators.nixosGenerate {
      inherit system specialArgs;
      format = "install-iso";
      modules = [
        (rootPath + "/modules/nixos/machine/nix.nix")
        (rootPath + "/nixos-secrets.nix")
        ({ pkgs, config, lib, ... }: {
          config =
            let
              lriutzelKeys = [
                # password protected private key file
                "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1pkTHUApo4oX3PLXnXcTLZ7xszEdeYJfBFEUyliYgD32INvsvQhl3ZmhZ1P5IMDmrMb/zd9dsMbtfY1fgy+unSMblb6RS7SxOt6vfifxNc1R7ylaa1HufgAhJHT+bSWNGPliA5Ds2XbdbPh3I6yRFT+V37QUz9EesDFaUC0JVEgqVOAUikSAGXhAeskTpQhD//32lEPwPM45iVS7Zix34LYrQ/RyVL9EKMRGLGFkJ3UgLsn6j8Wos7EM9YoW8s7lueShBcCFLqGus2Mjg71L14MWM1CCtaiFeBr04BtmhtvCjKJ505zfVLWLC8bg/URR6mIZABc1OqKRnm017tlJ3Q== lriutzel@gmail.com"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO/wQSQHq1Wmzbwg8uJM4vK/exUWmsT49kmkPdtJU0v lriutzel@gmail.com"

                # pin protected solo2 security key
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPxPFMNGK0tw467usZYAA1mjgB2owDFBQT939dzOlBWyAAAABHNzaDo= orange"
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINmfKdhabJag/k0w78kqBG1PL8w+WMv7xWp4VbkdhtINAAAABHNzaDo= black"
              ];
            in
            {
              users.users.nixos = {
                hashedPasswordFile = config.age.secrets.lriutzel-hashed-password.path;
                initialHashedPassword = lib.mkForce null;
                openssh.authorizedKeys.keys = lriutzelKeys;
              };

              environment.systemPackages = [
                pkgs.git
                pkgs.htop
                pkgs.tmux
              ];

              # IDK why it's needed but keep sshd running
              services.openssh.startWhenNeeded = mkForce false;

              # Make using wireless easier via nmtui-connect
              networking.networkmanager.enable = true;

              # Installer uses wpa-supplicant by default
              networking.wireless.enable = mkForce false;

              # Playing with iwd
              #environment.systemPackages = with pkgs; [ iwgtk ];
              networking.networkmanager.wifi.backend = "iwd";
              networking.wireless.iwd.enable = true;
              networking.wireless.iwd.settings = {
                General = {
                  AddressRandomization = "network";
                  AddressRandomizationRange = "full";
                  DisableANQP = false; # Hotspot 2.0 explore turning on
                };
                Network = {
                  EnableIPv6 = true;
                  RoutePriorityOffset = 300;
                };
                Settings = {
                  AutoConnect = true;
                  AlwaysRandomizeAddress = true;
                };
                Scan = {
                  InitialPeriodicScanInterval = 1;
                  MaximumPeriodicScanInterval = 60;
                };
              };
            };
        })
      ];
    };
}
