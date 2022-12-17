{ config, lib, ... }:

let 
  inherit (lib) mkForce;
  homeDir = config.home.homeDirectory;
in {
  config = lib.mkIf config.services.syncthing.enable {
    services.syncthing = {
      extraOptions = [
        "--config=${homeDir}/.config/syncthing"
        "--data=${homeDir}/.local/share/syncthing"
      ];
    };
  };
}
