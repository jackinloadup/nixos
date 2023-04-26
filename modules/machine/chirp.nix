{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkEnableOption genAttrs attrNames;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  imports = [ ];

  options.programs.chirp.enable = mkEnableOption "Enable chirp";

  config = mkIf config.programs.chirp.enable {
    environment.systemPackages = [ pkgs.chirp ];

    users.users = addExtraGroups normalUsers [ "dialout" ];
  };
}
