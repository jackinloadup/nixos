{
  self,
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) attrNames genAttrs;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  config = {
    hardware.i2c.enable = true;
    services.ddccontrol.enable = true;
    # pkgs that might be desired
    # ddccontrol-db
    # i2c-tools
    #
    users.users = addExtraGroups normalUsers ["i2c"];
  };
}
