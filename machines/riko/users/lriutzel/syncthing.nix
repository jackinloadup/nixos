# Syncthing configuration for lriutzel on riko
{ config, ... }:
let
  devices = import ../../../../modules/syncthing/devices.nix;
  folders = import ../../../../modules/syncthing/folders.nix;
in
{
  services.syncthing.settings = {
    inherit devices;

    folders = {
      "Lucas Documents" = folders.lriutzel-documents // {
        path = "${config.home.homeDirectory}/Documents";
      };

      "Lucas Pictures" = folders.lriutzel-pictures // {
        path = "${config.home.homeDirectory}/Pictures";
      };

      "Lucas Projects" = folders.lriutzel-projects // {
        path = "${config.home.homeDirectory}/Projects";
      };
    };
  };
}
