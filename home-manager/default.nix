{ inputs, pkgs, config, lib, nixosConfig, ... }:

with inputs;
let
  settings = import ../settings;
in
{
  imports = [
    ./alacritty.nix
    base16.hmModule
    ./development.nix
    ./foot.nix
    ./i3.nix
    ./neovim.nix
    ./sway.nix
    ./zoom.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ self.overlay nur.overlay ];

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
      enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
      userDirs.enable = true;

      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = "org.pwmt.zathura.desktop";
          "application/xhtml+xml" = "firefox.desktop";
          "text/html" = "firefox.desktop";
        };
      };
    };

    xsession.pointerCursor = {
      package = pkgs.quintom-cursor-theme;
      name = "Quintom_Ink";
      size = 32;
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

    programs.mpv.enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
    programs.mpv.config = {
      profile = "gpu-hq";
      force-window = true;
      video-sync ="display-resample";
      interpolation =true;
      ytdl-format = "bestvideo+bestaudio"; #TODO adjust for laptop screen size
      hwdec = "auto-safe"; # battery
      #cache-default = 4000000;
      #tscale = "oversample";
    };

    programs.home-manager.enable = true;

    programs.firefox = {
      enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
      package = pkgs.firefox-bin;
      #package = pkgs.wrapFirefox pkgs.firefox-esr {
      #  nixExtensions = [
      #    (pkgs.fetchFirefoxAddon {
      #      name = "ublock"; # Has to be unique!
      #      url = "https://addons.mozilla.org/firefox/downloads/file/3679754/ublock_origin-1.31.0-an+fx.xpi";
      #      sha256 = "1h768ljlh3pi23l27qp961v1hd0nbj2vasgy11bmcrlqp40zgvnr";
      #    })
      #  ];

      #  extraPolicies = {
      #    CaptivePortal = false;
      #    DisableFirefoxStudies = true;
      #    DisablePocket = true;
      #    DisableTelemetry = true;
      #    DisableFirefoxAccounts = true;
      #    FirefoxHome = {
      #      Pocket = false;
      #      Snippets = false;
      #    };
      #     UserMessaging = {
      #       ExtensionRecommendations = false;
      #       SkipOnboarding = true;
      #     };
      #  };

      #  extraPrefs = ''
      #    // Show more ssl cert infos
      #    lockPref("security.identityblock.show_extended_validation", true);
      #  '';
      #};
      #package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      #  #ffmpegSupport = true;
      #  #pipewireSupport = true;
      #  forceWayland = true;
      #  #extraPolicies = {
      #  #  ExtensionSettings = {};
      #  #};
      #};
    };

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
    };

    home.username = settings.user.username;
    home.homeDirectory = lib.mkOverride 10 "/home/${settings.user.username}";

    home.packages = with pkgs; (if (nixosConfig.machine.sizeTarget > 0 ) then [
      #unstable.neovim
      #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      imv # minimal image viewer

      libnotify # for notify-send

      iotop
      inetutils
      usbutils # alt busybox cope toybox
      nmap

      tealdeer # $tldr strace

      unzip # duh

      # darktile # alternative PTY to try out. GPU + go

      xdg-utils # for xdg-open

      bitwarden-cli

      python39Packages.youtube-dl # there is an alt youtube-dl-lite

      lftp

      units

    ] else []) ++ (if (nixosConfig.machine.sizeTarget > 1 ) then [

      # GUI
      zathura # PDF / Document viewer
      libreoffice # Office suite
      fractal # matrix client
      thunderbird # Email client
      tixati # bittorrent client
      mumble # voice chat application
      signal-desktop # messaging client
      chromium # web browser
      xfce.thunar # File manager
      #pantheon.elementary-files
      speedcrunch # calculator 
      nota # fancy cli calculator
      #flameshot
      gnome.vinagre

      #tor-browser-bundle-bin

      python39Packages.xdot # graphviz viewer
      graphviz

      ## Audio
      pavucontrol # GUI volume source/sink manager
      ## Video
      ffmpeg # used for firefox va-api accel with media.rdd-ffmpeg
      # Spotify opensource utils?
      spotify-tui # spotifyd ui
      spotifyd # music player no ui
      # NonFree
      spotify


      ## Debugging
      wireshark
      gparted

      ## Task/notes
      mindforger

      ## Wine Apps
      wineApps.winbox
      winetricks
      wineWowPackages.stable

      # TUI
      ## spreadsheet stuffs
      sc-im
      visidata

      ## Tasks/notes
      taskwarrior
      taskwarrior-tui

      ## networking
      nethogs
      ngrep
      fast-cli

      ## Audio
      playerctl
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
      # Display desktop notfications.
      dunst = {
        enable = true;

        #iconTheme = {
        #  package = pkgs.gnome.adwaita-icon-theme;
        #  name = "Adwaita";
        #};

        settings = {
          global = with settings.theme; {
            follow = "keyboard"; # Show notifications where the keyboard has foucs.
            font = "${font.normal.family} ${font.normal.style} ${toString(font.size)}";
            word_wrap = "yes";
            format = "<b>%s</b>\\n%b";
            frame_width = borderWidth; # Border size.
            geometry = "400x5-18+42"; # Size & location of notifications.
            markup = "full"; # Enable basic markup in messages.
            show_age_threshold = settings.timeouts.show_age_after;
            icon_position = "left";
            max_icon_size = 32; # Put a limit on image/icon size.
            padding = 6; # Vertical padding
            horizontal_padding = 6;
            separator_color = "frame"; # Match to the frame color.
            separator_height = borderWidth; # Space between notifications.
            sort = "yes"; # Sort messages by urgency.
            stack_duplicates = true;
            hide_duplicate_count = false;
            show_indicators = true;
            history_lengh = 30;
            sticky-history = "yes";
            dmenu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term=alacritty --dmenu='bemenu -i -l 10'";
            browser = "${pkgs.xdg-utils}/bin/xdg-open";
          };

          # @TODO these shortcuts should be using super not ctrl as they are workspace level commands
          shortcuts = {
            close = "ctrl+space";
            close_all = "ctrl+shift+space";
            history = "ctrl+grave";
            context = "ctrl+shift+period";
          };

          urgency_low = with config.lib.base16.theme; {
            background ="#${base00-hex}";
            foreground ="#${base04-hex}";
            frame_color ="#${base03-hex}";
            timeout = "15s";
          };

          urgency_normal = with config.lib.base16.theme; {
            background ="#${base00-hex}";
            foreground ="#${base04-hex}";
            frame_color ="#${base0A-hex}";
            timeout = "30s";
          };

          urgency_critical = with config.lib.base16.theme; {
            background ="#${base00-hex}";
            foreground ="#${base04-hex}";
            frame_color ="#${base0B-hex}";
            timeout = "1d";
          };
        };
      };

      # Add the network manager to the status bar.
      network-manager-applet.enable = true;

      # Add the audio manager to the status bar.
      pasystray.enable = true;

      # Set a background image.
      #random-background = {
      #  enable = true;
      #  imageDirectory = toString ./art;
      #};

      # Manage removeable media.
      udiskie = {
        enable = true;
        tray = "auto";
      };
    };

     ## add config above here
  };
}
