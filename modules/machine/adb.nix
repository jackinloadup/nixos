{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption genAttrs attrNames;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  imports = [ ];

  config = mkIf config.programs.adb.enable {
    users.users = addExtraGroups normalUsers ["adbusers"];
  };
}
