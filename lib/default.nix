{lib, inputs, ... }:

let 
  inherit (builtins) attrNames attrValues isAttrs readDir head length
    toPath listToAttrs
    ;
  inherit (lib) filterAttrs mapAttrs' nameValuePair mapAttrs mapAttrsToList
    forEach
    ;
  rootPath = ../.;
  defineModule = name: dir: {
    name = name;
    value = import (rootPath + ("/" + dir + "/" + name));
  };
in

rec {

  importModulesDir = dir: listToAttrs (
    map (name: defineModule name dir) (attrNames (readDir  (toPath  rootPath + "/${dir}")))
  );
  nixosModules = importModulesDir "modules";
  nixosUsers = importModulesDir "users";
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
