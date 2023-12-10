{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "krita.desktop"
        "kdenlive.desktop"
        "obs.desktop"
        "filezilla.desktop"
        "signal-desktop.desktop"
        "simple-scan.desktop"
      ];

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "caffeine@patapon.info"
        "org.gnome.Shell.Extensions.GSConnect"
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
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/pills-d.webp";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/pills-d.webp";
    };
    "org/gnome/simple-scan" = {
      document-type = "photo";
      #paper-height = 2794;
      #paper-width = 2159;
      save-directory = "file:///home/criutzel/Downloads/";
      save-format = "image/png";
    };
  };
  gtk.gtk3.bookmarks = [
    "sftp://truenas.home.lucasr.com/mnt/storage Gumdrop-NAS"
    "ssh://seed.tac0bell.com:2222/home/user/Downloads Seedbox"
  ];

  home.packages = [
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.syncthing-indicator
  ];
}
