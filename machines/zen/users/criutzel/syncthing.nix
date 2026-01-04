# Syncthing configuration for criutzel on zen
{ config, ... }:
let
  devices = import ../../../../modules/syncthing/devices.nix;
  folders = import ../../../../modules/syncthing/folders.nix;
in
{
  services.syncthing.settings = {
    inherit devices;

    folders = {
      "Christine Mobile Videos" = folders.criutzel-mobile-videos // {
        path = "${config.home.homeDirectory}/Videos/Mobile Videos";
      };

      "Christine Sync" = folders.criutzel-sync // {
        path = "/persist/home/criutzel/Sync";
      };

      "Christine Desktop" = folders.criutzel-desktop // {
        path = "/persist/home/criutzel/Desktop";
      };

      "Christine Documents" = folders.criutzel-documents // {
        path = "/persist/home/criutzel/Documents";
      };

      "Christine Downloads" = folders.criutzel-downloads // {
        path = "/persist/home/criutzel/Downloads";
      };

      "Christine Music" = folders.criutzel-music // {
        path = "/persist/home/criutzel/Music";
      };

      "Christine Pictures" = folders.criutzel-pictures // {
        path = "/persist/home/criutzel/Pictures";
      };

      "Christine Videos" = folders.criutzel-videos // {
        path = "/persist/home/criutzel/Videos";
      };
    };
  };
}
