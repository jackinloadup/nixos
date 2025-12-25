{ lib
, config
, ...
}:
let
  inherit (lib) attrNames genAttrs mkDefault;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (_user: { extraGroups = groups; }));
in
{
  config = {
    hardware.i2c.enable = mkDefault true;
    services.ddccontrol.enable = mkDefault true;
    # pkgs that might be desired
    # ddccontrol-db
    # i2c-tools
    #
    users.users = addExtraGroups normalUsers [ "i2c" ];
  };
}
