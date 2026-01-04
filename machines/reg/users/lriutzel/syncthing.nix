# Syncthing configuration for lriutzel on reg
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
        path = "/persist/home/lriutzel/Documents";
      };

      "Lucas Projects" = folders.lriutzel-projects // {
        path = "/persist/home/lriutzel/Projects";
      };

      "Lucas Pictures" = folders.lriutzel-pictures // {
        path = "/persist/home/lriutzel/Pictures";
      };

      "Lucas Mobile Camera" = folders.lriutzel-mobile-camera // {
        path = "${config.home.homeDirectory}/Pictures/Mobile-Camera";
      };

      "Android Camera" = folders.lriutzel-android-camera // {
        path = "${config.home.homeDirectory}/Pictures/Android Camera";
      };
    };
  };
}
