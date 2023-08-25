{
  config,
  pkgs,
  nixosConfig,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkDefault;
  settings = import ../../settings;
  ifGraphical = nixosConfig.machine.sizeTarget > 1;
in {
  dconf.settings = {
    "org/gnome/shell" = {
      always-show-log-out = true; # Always show logout
      favorite-apps = [
        "firefox.desktop"
        "neovim.desktop"
        "org.gnome.Terminal.desktop"
        "spotify.desktop"
        "virt-manager.desktop"
        "org.gnome.Nautilus.desktop"
      ];
      disable-user-extensions = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
        "dash-to-panel@jderose9.github.com"
        "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      workspace-names = ["Main"];
    };
    #"org/gnome/desktop/background" = {
    #  picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-l.png";
    #  picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
    #};
    #"org/gnome/desktop/screensaver" = {
    #  picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
    #  primary-color = "#3465a4";
    #  secondary-color = "#000000";
    #};
    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "standard";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      default-sort-order = "type";
      search-filter-time-type = "last_modified";
      search-view = "list-view";
    };
    #"org/gnome/desktop/input-sources" = {
    #  current = "uint32 0";
    #  sources = [(mkTuple ["xkb" "br"]) (mkTuple ["xkb" "us"])];
    #  xkb-options = [ "terminate:ctrl_alt_bksp" ];
    #};
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = false;
    };
    "org/gnome/desktop/privacy" = {
      disable-microphone = true;
      report-technical-problems = false;
    };
    "org/gnome/system/location" = {
      enabled = false;
    };
    "org/gnome/desktop/periphereals/touchpad" = {
      tap-to-click = false;
      disable-while-typing = false;
      two-finger-scrolling-enabled = true;
      speed = 0.20;
    };
    "org/gnome/desktop/peripherals/mouse".speed = 0.20;
    # Don't suspend on power
    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
  };

  home.pointerCursor = {
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Ink";
    size = 32;
    gtk.enable = mkDefault ifGraphical;
  };

  gtk = with settings.theme; {
    enable = ifGraphical;
    font.name = "${font.normal.family} ${font.normal.style} ${toString font.size}";
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      #name = "palenight";
      #package = pkgs.palenight-theme;
      name = gtk.name;
      package = pkgs.${gtk.package};
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    # Shows in nemo
    gtk3.bookmarks = [
      "sftp://truenas/mnt/ Gumdrop-NAS"
    ];
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.packages = with pkgs;
    [
      drm_info # Small cli utility to dump info about DRM devices

      gnomeExtensions.user-themes
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.vitals
      gnomeExtensions.dash-to-panel
      gnomeExtensions.sound-output-device-chooser
      gnomeExtensions.space-bar

      gtk-engine-murrine # Unable to locate theme engine in module_path: "murrine"
      clearlooks-phenix
    ]
    ++ lib.optionals ifGraphical [
      #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

      # GUI
      # ---------------------------------------
      libreoffice # Office suite
      libnotify # for notify-send
      # darktile # alternative PTY to try out. GPU + go

      # Spelling
      hunspell
      hunspellDicts.en_US-large
      hyphen

      xfce.thunar # File manager
      #pantheon.elementary-files
      cinnamon.nemo # File manager
      #flameshot
      gnome.gnome-disk-utility
      #calibre # ebook tool,  assist with kindle
      #obsidian # Markdown information archive

      ## Audio
      pavucontrol # GUI volume source/sink manager

      ## Fun
      cavalier
    ];

  programs.chromium.enable = true;

  services = lib.mkIf ifGraphical {
    playerctld.enable = true;

    # Add the network manager to the status bar.
    network-manager-applet.enable = true;

    # Add the audio manager to the status bar.
    pasystray.enable = true;

    # Set a background image.
    #random-background = {
    #  enable = true;
    #  imageDirectory = toString ./art;
    #};

    #kdeconnect = {
    #  enable = true;
    #  indicator = true;
    #};

    # Manage removeable media.
    udiskie = {
      enable = true;
      tray = "auto";
    };
  };

  xdg = {
    userDirs.enable = mkDefault ifGraphical;

    mimeApps = {
      enable = mkDefault ifGraphical;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";

        "message/rfc822" = "thunderbird.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";

        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";

        "inode/directory" = "nemo.desktop";
      };
    };
  };
}
