{ inputs, pkgs, config, ... }: 

with inputs;
let
  settings = import ../settings;
in
{
  imports = [
    ./sway.nix
    ./alacritty.nix
    ../common/neovim
    base16.hmModule
  ];

  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays =
      [ self.overlay-unstable self.overlay nur.overlay ];

    themes.base16 = {
      enable = true;
      #scheme = "solarized";
      #variant = "solarized-dark";
      scheme = "gruvbox";
      variant = "gruvbox-dark-hard";
      #variant = "gruvbox-dark-medium";
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontName = "FiraCode Nerd Font";
        fontSize = "12";
      };
    };


    programs.bash.enable = true;
    programs.bash.initExtra = ''
      source ${config.lib.base16.templateFile { name = "shell"; }}

      # if tty1 then dont fork, instead transfer execution to sway
      # thus if sway crashes the resulting terminal will not be logged in
      [[ "$(tty)" == /dev/tty1 ]] && exec sway
    '';

    programs.mpv.enable = true;
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

    programs.git = {
      enable = true;
      userName = settings.user.name;
      userEmail = settings.user.email;
    };

    programs.firefox = {
      enable = true;
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
      EDITOR = "vim";
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      NVIM_TUI_ENABLE_TRUE_COLOR = 1;
      NVIM_TUI_ENABLE_CURSOR_SHAPE = 2; # blink cursor maybe? https://github.com/neovim/neovim/pull/5977

      TERMINFO_DIRS="/home/lriutzel/.nix-profile/share/terminfo";
      WSLENV="TERMINFO_DIRS";
    };

    home.username = settings.user.username;
    home.homeDirectory = "/home/${settings.user.username}";

    home.packages = with pkgs; [
      #unstable.neovim
      #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      pavucontrol # GUI volume source/sink manager
      zathura # PDF / Document viewer
      libreoffice # Office suite
      fractal # matrix client
      thunderbird # Email client
      #firefox # Web browser
      tixati # bittorrent client
      mumble # voice chat application
      imv # minimal image viewer

      libnotify # for notify-send

      iotop
      inetutils
      usbutils # alt busybox cope toybox

      nmap

      signal-desktop

      # Spotify opensource utils?
      spotify-tui # spotifyd ui
      spotifyd # music player no ui
      # NonFree
      spotify
      zoom-us

      #playerctl??
      tealdeer # $tldr strace

      unzip # duh

      # darktile # alternative TTY to try out. GPU + go

      xdg-utils # for xdg-open



      bitwarden-cli

      python39Packages.youtube-dl # there is an alt youtube-dl-lite

      tor-browser-bundle-bin

      gnome.simple-scan

      xfce.thunar
      #pantheon.elementary-files

      python39Packages.xdot # graphviz viewer
      graphviz

      playerctl
    ];

    services = {
      playerctld.enable = true;
      # Display desktop notfications.
      dunst = {
        enable = true;

        settings = {
          global = with settings.theme; {
            follow = "keyboard"; # Show notifications where the keyboard has foucs.
            font = "${font.normal.family} ${font.normal.style} ${toString(font.size)}";
            word_wrap = "yes";
            format = "<b>%s</b>\\n%b%p";
            frame_width = 2; # Border size.
            geometry = "400x5-18+42"; # Size & location of notifications.
            markup = "full"; # Enable basic markup in messages.
            show_age_threshold = 60;
            max_icon_size = 32; # Put a limit on image/icon size.
            padding = 6; # Vertical padding
            horizontal_padding = 6;
            separator_color = "frame"; # Match to the frame color.
            separator_height = 2; # Space between notifications.
            sort = "yes"; # Sort messages by urgency.
            stack_duplicates = true;
            hide_duplicate_count = false;
            show_indicators = true;
            history_lengh = 30;
            sticky-history = "yes";
            dmenu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term=alacritty --dmenu='bemenu -i -l 10'";
            browser = "${pkgs.xdg-utils}/bin/xdg-open";
          };

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
            timeout = "30s";
          };

          urgency_normal = with config.lib.base16.theme; {
            background ="#${base00-hex}";
            foreground ="#${base04-hex}";
            frame_color ="#${base0A-hex}";
            timeout = "1m";
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
      network-manager-applet = {
        enable = true;
      };

      # Add the audio manager to the status bar.
      pasystray = {
        enable = true;
      };

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
