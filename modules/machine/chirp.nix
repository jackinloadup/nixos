{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.machine;
  normalUsers = attrNames config.home-manager.users;
  addExtraGroups = users: groups: (genAttrs users (user: {extraGroups = groups;}));
in {
  imports = [ ];

  options.machine.chirp = mkEnableOption "Enable chirp";

  config = mkIf config.machine.chirp {
    environment.systemPackages = with pkgs; [ chirp ];

    users.users = addExtraGroups normalUsers [ "dialout" ];
  };
}
