{
  config,
  pkgs,
  nixosConfig,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkDefault getBin;
  settings = import ../../settings;
  ifGraphical = nixosConfig.machine.sizeTarget > 1;
in {
  imports = [
    ./navigation.nix

  ];

  config = {
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
        screensaver = [ "<Super>Delete" ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = "${pkgs.gnome-console}/bin/kgx";
        name = "Launch Terminal";
      };
      "org/gnome/settings-daemon/plugins/power" = {
        idle-dim = true;
        power-button-action = "suspend";
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-timeout = 1200;
        sleep-inactive-battery-type = "suspend";
      };
      "org/gnome/shell" = {
        always-show-log-out = true; # Always show logout
        disable-user-extensions = false;
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        clock-format = "12h";
        clock-show-date = true;
        clock-show-seconds = false;
        clock-show-weekday = true;
        enable-animations = mkDefault true;
        enable-hot-corners = false;
        #font-antialiasing = "grayscale";
        #font-hinting = "slight";
        #gtk-im-module = "ibus";
        locate-pointer = false;
        show-battery-percentage = true;
        toolkit-accessibility = false;
      };
      "org/gnome/desktop/peripherals/keyboard" = {
        numlock-state = false;
      };
      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "default";
        left-handed = false;
        natural-scroll = false;
        speed = 0.75;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        #click-method = "fingers";
        disable-while-typing = true;
        edge-scrolling-enabled = false;
        natural-scroll = false;
        send-events = "enabled";
        speed = 0.5;
        tap-to-click = false;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
        event-sounds = true;
      };
      "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        background-color = "rgb(23,20,33)";
        font = "Monospace 16";
        foreground-color = "rgb(208,207,204)";
        use-system-font = false;
        use-theme-colors = false;
      };
      #"org/gnome/desktop/wm/preferences" = {
      #  workspace-names = ["Main"];
      #};
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.png";
        primary-color = "#3465a4";
        secondary-color = "#000000";
      };
      #"org/gnome/nautilus/icon-view" = {
      #  default-zoom-level = "standard";
      #};

      #"org/gnome/nautilus/preferences" = {
      #  default-folder-viewer = "icon-view";
      #  default-sort-order = "type";
      #  search-filter-time-type = "last_modified";
      #  search-view = "list-view";
      #};
      #"org/gnome/desktop/input-sources" = {
      #  current = "uint32 0";
      #  sources = [(mkTuple ["xkb" "br"]) (mkTuple ["xkb" "us"])];
      #  xkb-options = [ "terminate:ctrl_alt_bksp" ];
      #};
      #"org/gnome/desktop/privacy" = {
      #  disable-microphone = true;
      #  report-technical-problems = false;
      #};
      "org/gnome/system/location" = {
        enabled = false;
      };
    };

    home.pointerCursor = {
      package = pkgs.quintom-cursor-theme;
      name = "Quintom_Ink";
      size = 32;
      gtk.enable = mkDefault ifGraphical;
    };

    gtk = with settings.theme; {
      enable = mkDefault ifGraphical;
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

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    qt = {
      enable = mkDefault true;
      platformTheme.name = mkDefault "adwaita-dark";
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
        #cinnamon.nemo # File manager
        #flameshot
        gnome.nautilus
        gnome.gnome-disk-utility
        #calibre # ebook tool,  assist with kindle
        #obsidian # Markdown information archive

        ## Audio
        pavucontrol # GUI volume source/sink manager
        pwvucontrol # GUI volume source/sink manager pipewire


        ## Fun
        cavalier

        usbview # GUI for usb devices
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
      # enable management of XDG base directories
      enable = mkDefault ifGraphical;
      configFile."mimeapps.list".force = true;
      userDirs.enable = mkDefault ifGraphical;

      mimeApps = {
        enable = mkDefault ifGraphical;
        defaultApplications = {
          "application/pdf" = "org.pwmt.zathura.desktop";

          "message/rfc822" = "thunderbird.desktop";
          "x-scheme-handler/mailto" = "thunderbird.desktop";

          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";

          "inode/directory" = "nautilus.desktop";
          #"inode/directory" = "nemo.desktop";
        };
      };
    };

    ## gnome-keyring keeps not getting started in time.
    #systemd.user.services.nextcloud-client.Unit.Requires =
    #  "gnome-keyring.service";
    #};
  };
}
