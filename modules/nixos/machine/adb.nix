{ lib
, config
, ...
}:
let
  inherit (lib) mkIf genAttrs attrNames;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (_user: { extraGroups = groups; }));
in
{
  imports = [ ];

  config = mkIf config.programs.adb.enable {
    users.users = addExtraGroups normalUsers [ "adbusers" ];
  };
}
