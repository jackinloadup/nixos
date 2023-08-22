{
  lib,
  inputs,
  ...
}: let
  inherit
    (builtins)
    attrNames
    attrValues
    isAttrs
    readDir
    head
    length
    toPath
    listToAttrs
    ;
  inherit
    (lib)
    filterAttrs
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
    value = importOverlay path inputs;
  };
  importModuleSet = name: path: {
    name = name;
    value = import path;
  };
  importOverlay = path: args: (final: prev: (import path args) final prev);
  filesInDir = dir: attrNames (readDir (toPath rootPath + "/${dir}"));

  specialArgs = {inherit inputs;};
in rec {
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

  mkNixosSystem = pkgs: system: hostname:
    pkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules =
        (import (rootPath + "/machines/${hostname}/modules.nix") {inherit inputs;})
        ++ attrValues nixosModules
        ++ attrValues nixosUsers
        ++ [
          inputs.secrets.nixosModules.default
          (rootPath + "/machines/${hostname}/configuration.nix")
        ];
    };

  mkNixosNoModulesSystem = pkgs: system: hostname:
    pkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules =
        (import (rootPath + "/machines/${hostname}/modules.nix") {inherit inputs;})
        ++ [
          inputs.secrets.nixosModules.default
          (rootPath + "/machines/${hostname}/configuration.nix")
        ];
    };

  mkNixosSystemGenerator = pkgs: system: hostname:
    nixos-generators.nixosGenerate {
      inherit system specialArgs;
      format = "install-iso";
      modules = [
        inputs.secrets.nixosModules.default
        (rootPath + "/modules/machine/nix.nix")
        ({
          pkgs,
          config,
          ...
        }: {
          config = {
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
