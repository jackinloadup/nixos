{ config, pkgs, nixosConfig, lib, inputs, ... }:

let
  inherit (lib) mkDefault;
  settings = import ../settings;
  ifGraphical = nixosConfig.machine.sizeTarget > 1;
in {
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

  home.pointerCursor = {
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Ink";
    size = 32;
    gtk.enable = mkDefault ifGraphical;
  };

  gtk = with settings.theme; {
    enable = ifGraphical;
    font.name = "${font.normal.family} ${font.normal.style} ${toString font.size}";
    theme.name = gtk.name;
    theme.package = pkgs.${gtk.package};
  };

  home.packages = with pkgs; [
    drm_info # Small cli utility to dump info about DRM devices
  ] ++ lib.optionals ifGraphical [
    #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

    # GUI
    # ---------------------------------------
    #libreoffice # Office suite
    libnotify # for notify-send
    # darktile # alternative PTY to try out. GPU + go

    # Spelling
    hunspell
    hunspellDicts.en_US-large
    hyphen

    chromium # web browser
    xfce.thunar # File manager
    #pantheon.elementary-files
    cinnamon.nemo # File manager
    #flameshot
    gnome.gnome-disk-utility
    #calibre # ebook tool,  assist with kindle
    #obsidian # Markdown information archive

    ## Audio
    pavucontrol # GUI volume source/sink manager
  ];

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
}
