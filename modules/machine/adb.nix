{ lib, pkgs, config, ... }:
with lib;
let
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  imports = [ ];

  options.machine.adb = mkEnableOption "Enable ADB";

  config = mkIf config.machine.adb {
    programs.adb.enable = true;

    users.users = addExtraGroups normalUsers ["adbusers"];
  };
}
