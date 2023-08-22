{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption genAttrs attrNames;
  normalUsers = attrNames config.users.users;
  addHomeFile = users: path: file: (genAttrs users (user: {home.file.${path} = file;}));

  cfg = config.machine;
in {
  config = mkIf cfg.gaming {
    # RollerCoaster Tycoon 2 openrct2 multiplayer
    networking.firewall.allowedTCPPorts = [11753];
    networking.firewall.allowedUDPPorts = [11753];
  };
}
