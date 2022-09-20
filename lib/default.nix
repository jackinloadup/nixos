{lib, inputs, ... }:

let 
  inherit (builtins) attrNames attrValues isAttrs readDir head length
    toPath listToAttrs
    ;
  inherit (lib) filterAttrs mapAttrs' nameValuePair mapAttrs mapAttrsToList
    forEach
    ;
  inherit (lib.strings) removeSuffix;

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
  filesInDir = dir: attrNames (readDir  (toPath  rootPath + "/${dir}"));
in

rec {

  importDirOfOverlays = dir: listToAttrs (
    map (name: importOverlaySet name (buildPath dir name)) (filesInDir dir)
  );
  importDirOfModules = dir: listToAttrs (
    map (name: importModuleSet name (buildPath dir name)) (filesInDir dir)
  );
  nixosModules = importDirOfModules "modules";
  nixosUsers = importDirOfModules "users";
  mkNixosSystem = pkgs: system: hostname:
    pkgs.lib.nixosSystem {
      system = system;
      modules = 
        ( import (rootPath + "/machines/${hostname}/modules.nix") { nixos-hardware = inputs.nixos-hardware; })
        ++ attrValues nixosModules
        ++ attrValues nixosUsers
        ++ [
          inputs.secrets.nixosModules.default
          ( rootPath + "/machines/${hostname}/configuration.nix")
        ];
      specialArgs = { inherit inputs; };
    };
}
