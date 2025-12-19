{
  lib,
  inputs,
  flake,
  ...
}: let
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

  specialArgs = {flake = { inherit inputs;}; };
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

  machines = attrNames (readDir (rootPath + "/machines"));
  machinesHasConfig = (host: pathExists (rootPath + "/machines/${host}/configuration.nix"));
  machinesWithConfig = filter (host: machinesHasConfig host) machines;

  allNixosSystems = genAttrs machinesWithConfig mkNixosSystem;

  mkNixosSystem = (name:
    flake.nixos-unified.lib.mkLinuxSystem
      { home-manager = true; }
      { imports = [ (rootPath + "/machines/${name}/configuration.nix") ]; }
    );

  mkNixosSystemGenerator = pkgs: system: hostname:
    nixos-generators.nixosGenerate {
      inherit system specialArgs;
      format = "install-iso";
      modules = [
        (rootPath + "/modules/nixos/machine/nix.nix")
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
