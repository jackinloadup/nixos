# Syncthing configuration for criutzel on kanye
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
        path = "${config.home.homeDirectory}/Videos";
      };

      "Christine Sync" = folders.criutzel-sync // {
        path = "${config.home.homeDirectory}/Sync";
      };

      "Christine Desktop" = folders.criutzel-desktop // {
        path = "${config.home.homeDirectory}/Desktop";
      };

      "Christine Documents" = folders.criutzel-documents // {
        path = "${config.home.homeDirectory}/Documents";
      };

      "Christine Downloads" = folders.criutzel-downloads // {
        path = "${config.home.homeDirectory}/Downloads";
      };

      "Christine Music" = folders.criutzel-music // {
        path = "${config.home.homeDirectory}/Music";
      };

      "Christine Pictures" = folders.criutzel-pictures // {
        path = "${config.home.homeDirectory}/Pictures";
      };

      "Notification Sounds" = folders.shared-notification-sounds // {
        path = "${config.home.homeDirectory}/Music/Notification-Sounds";
      };
    };
  };
}
