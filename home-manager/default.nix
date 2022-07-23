{ inputs, pkgs, config, lib, nixosConfig, ... }:

with inputs;
let
  settings = import ../settings;
  ifGraphical = if (nixosConfig.machine.sizeTarget > 1) then true else false;
in
{
  imports = [
    (import "${inputs.impermanence}/home-manager.nix")
    ./alacritty.nix
    base16.hmModule
    ./development.nix
    ./dunst.nix
    ./firefox.nix
    ./foot.nix
    ./i3.nix
    ./mpv.nix
    ./neovim/default.nix
    ./sway/default.nix
    ./impermanence.nix
    #./task-warrior
    #./zoom.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      self.overlays.default
      nur.overlay
    ];

    nix.package = pkgs.nix;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
    '';

    themes.base16 = with settings.theme; {
      enable = true;
      scheme = base16.scheme;
      variant = base16.variant;
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontName = font.mono.family;
        fontSize = font.size;
      };
    };

    xdg = {
      enable = true;
      userDirs.enable = true;

      mimeApps = {
        enable = true;
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

    xsession = {
      enable = true;
    };

    home.keyboard = null; # only works with x11 i believe
    home.pointerCursor = {
        package = pkgs.quintom-cursor-theme;
        name = "Quintom_Ink";
        size = 32;
        gtk.enable = true;
        x11.enable = true;
      };

    gtk = with settings.theme; {
      enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
      font.name = "${font.normal.family} ${font.normal.style} ${toString font.size}";
      theme.name = gtk.name;
      theme.package = pkgs.${gtk.package};
    };

    programs.bash.enable = true;
    programs.bash.initExtra = ''
      source ${config.lib.base16.templateFile { name = "shell"; }}
      eval "$(starship init bash)"
    '';

    programs.readline = {
      enable = true;
      bindings = {
        "\\C-h" = "backward-kill-word";
      };
      extraConfig = ''
set editing-mode vi

set show-mode-in-prompt on
set vi-ins-mode-string "\1\e[5 q\2"
set vi-cmd-mode-string "\1\e[2 q\2"

set keymap vi-command
# j and k should search for the string of characters preceding the cursor
"k": history-search-backward
"j": history-search-forward

set keymap vi-insert
# inoremap jk <Esc>
"jk": vi-movement-mode
      '';
    };


    programs.home-manager.enable = true;


    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "21.05";

    home.sessionVariables = {
      TERMINFO_DIRS="${config.home.homeDirectory}/.nix-profile/share/terminfo";
      WSLENV="TERMINFO_DIRS";
      XAUTHORITY="${config.home.homeDirectory}/.Xauthority";
      NIXOS_CONFIG="${config.home.homeDirectory}/dotfiles/flake.nix";
      NIX_PATH="nixos-config=/home/lriutzel/dotfiles/flake.nix:$NIX_PATH";
    };

    home.username = settings.user.username;
    home.homeDirectory = lib.mkOverride 10 "/home/${settings.user.username}";

    home.packages = with pkgs; (if (nixosConfig.machine.sizeTarget > 0 ) then [
      iotop
      inetutils
      usbutils # an alternative could be busybox cope toybox
      unzip # duh
      lftp

      units
    ] else []) ++ (if (nixosConfig.machine.sizeTarget > 1 ) then [
      #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

      # GUI
      # ---------------------------------------
      zathura # PDF / Document viewer
      libreoffice # Office suite
      libnotify # for notify-send
      imv # minimal image viewer
      # darktile # alternative PTY to try out. GPU + go

      # Spelling
      hunspell
      hunspellDicts.en_US-large
      hyphen

      #freeoffice # office suite UNFREE
      fractal # matrix client
      nheko   # matrix client
      thunderbird # Email client
      tixati # bittorrent client
      #mumble # voice chat application
      #nur.repos.arc.packages.mumble_1_4
      signal-desktop # messaging client
      chromium # web browser
      xfce.thunar # File manager
      #pantheon.elementary-files
      cinnamon.nemo
      speedcrunch # calculator 
      nota # fancy cli calculator
      #flameshot
      gnome.vinagre
      gnome.gnome-disk-utility
      #calibre # ebook tool,  assist with kindle
      #obsidian # Markdown information archive

      exodus # Cryptowallet
      electron-cash # BCH walle

      tor-browser-bundle-bin

      python39Packages.xdot # graphviz viewer
      graphviz
      blender

      ## Video
      handbrake
      lbry
      obs-studio
      obs-studio-plugins.wlrobs
      obs-studio-plugins.obs-multi-rtmp

      ## Audio
      pavucontrol # GUI volume source/sink manager
      pulsemixer # TUI volume source/sink manager
      # Spotify opensource utils?
      spotify-tui # spotifyd ui
      spotifyd # music player no ui
      # NonFree
      spotify

      cawbird # twitter client

      ## Debugging
      wireshark
      gparted

      ## Task/notes
      mindforger

      ## Wine Apps
      wineApps.winbox
      #winetricks
      #wineWowPackages.stable

      # TUI
      # ----------------
      jless # json viewer
      tealdeer # $tldr strace
      #bitwarden-cli
      python39Packages.youtube-dl # there is an alt youtube-dl-lite
      xdg-utils # for xdg-open
      #nur.repos.ambroisie.comma # like nix-shell but more convinient
      nix-index
      nmap
      nixos-shell

      ## spreadsheet stuffs
      sc-im
      visidata

      # TUI to GUI helpers
      #dragon-drop # in unstable its maybe xdragon

      ## networking
      nethogs
      ngrep
      fast-cli

      ## Audio
      playerctl

      # Fun
      asciiquarium # Fun aquarium animation
      cmatrix # Fun matrix animation
    ] else []);

    services = lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) {
      gpg-agent = {
        enable = true;
        enableExtraSocket = false;
        enableScDaemon = false;
        enableSshSupport = true;
        defaultCacheTtl = 30;
        defaultCacheTtlSsh = 30;
        maxCacheTtl = 3600; # 1 hour
        maxCacheTtlSsh = 3600; # 1 hour
      };
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

    home.file."${config.xdg.configHome}/htop/htoprc".source = ./htoprc;

    ## add config above here
  };
}
