{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  normalUsers = attrNames config.home-manager.users;
  userHasService = users: service: any (users: config.home-manager.users.${user}.services.${service}.enable) users;
in {
  imports = [];

  config =
    {}
    // mkIf (userHasService normalUsers "syncthing") {
      networking.firewall.allowedTCPPorts = [22000];
      networking.firewall.allowedUDPPorts = [22000];
    }
    // mkIf services.syncthing.enable {
      services.syncthing = {
        extraOptions = {
          gui = {
            theme = "black";
          };
        };
        #guiAddress = mkIf cfg.server "syncthing.${domain}";¶
        # if syncthing runs as a user
        #user = username
        #configDir = "/home/${username}/.config/syncthing";
        #dataDir = "/home/${username}/.local/share/syncthing";
      };
    };
}
