{pkgs, lib, ...}: let
  inherit (lib) mkForce;
in {
  config = {
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "kdenlive.desktop"
          "obs.desktop"
          "signal-desktop.desktop"
        ];

        # `gnome-extensions list` for a list
        enabled-extensions = [
          "syncthing@gnome.2nv2u.com"
          #  "user-theme@gnome-shell-extensions.gcampax.github.com"
          #  "trayIconsReloaded@selfmade.pl"
          #  "Vitals@CoreCoding.com"
          #  "dash-to-panel@jderose9.github.com"
          #  "sound-output-device-chooser@kgshank.net"
          #  "space-bar@luchrioh"
        ];
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/keys-l.webp";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/keys-d.webp";
      };
      "org/gnome/simple-scan" = {
        document-type = "text";
        #paper-height = 2794;
        #paper-width = 2159;
        save-directory = "file:///home/lriutzel/Downloads/";
        save-format = "application/pdf";
      };
      "org/gnome/desktop/interface" = {
        enable-animations = mkForce false;
        #enable-hot-corners = true;
        #font-antialiasing = "grayscale";
        #font-hinting = "slight";
        #gtk-im-module = "ibus";
        locate-pointer = false;
        toolkit-accessibility = false;
      };
    };

    gtk.gtk3.bookmarks = [
      "sftp://truenas.home.lucasr.com/mnt Gumdrop-NAS"
      "ssh://seed.tac0bell.com:2222/home/user/Downloads Seedbox"
    ];

    home.packages = [
      pkgs.gnomeExtensions.syncthing-indicator
      #pkgs.gnomeExtensions.gsconnect
    ];
  };
}
