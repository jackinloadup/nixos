{ inputs, pkgs, config, lib, nixosConfig, ... }:

with inputs;
let
  settings = import ../settings;
in
{
  imports = [
    ./sway.nix
    ./i3.nix
    ./alacritty.nix
    ./neovim.nix
    base16.hmModule
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

    gtk = with settings.theme; {
      enable = if (nixosConfig.machine.sizeTarget > 1 ) then true else false;
      font.name = "${font.normal.family} ${font.normal.style} ${toString font.size}";
      theme.name = gtk.name;
      theme.package = pkgs.${gtk.package};
    };

    programs.bash.enable = true;
    programs.bash.initExtra = ''
      source ${config.lib.base16.templateFile { name = "shell"; }}
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

    programs.git = {
      enable = true;
      userName = settings.user.name;
      userEmail = settings.user.email;

      delta.enable = true;

      aliases = {
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        lb = "!git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf(\"  \\033[33m%s: \\033[37m %s\\033[0m\\n\", substr($2, 1, length($2)-1), $1)}'";
        tracked = "for-each-ref --format='%(refname:short) <- %(upstream:short)' refs/heads";
        poke = "!git ls-remote origin | grep -w refs/heads/poke && git push origin :poke || git push origin master:poke";
        board = "!f() { php $HOME/bin/gitboard $@; }; f";
        co = "checkout";
        ci = "commit";
        cia = "commit --amend";
        d = "diff";
        ds = "diff --staged";
        s = "status";
        st = "status";
        b = "branch";
        br = "branch";
        p = "pull --rebase";
        pu = "push";
        git = "!exec git";
      };

      ignores = [
        "*~"
        "*.pyc"
        "*.swo"
        "*.swp"
        ".DS_Store"
        ".settings.xml"
      ];

      extraConfig = {
        init.defaultBranch = "master";
        core.editor = "nvim";
        #protocol.keybase.allow = "always";
        #credential.helper = "store --file ~/.git-credentials";
        #pull.rebase = "false";
      };
    };

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
      EDITOR = "vim";
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      NVIM_TUI_ENABLE_TRUE_COLOR = 1;
      NVIM_TUI_ENABLE_CURSOR_SHAPE = 2; # blink cursor maybe? https://github.com/neovim/neovim/pull/5977

      TERMINFO_DIRS="/home/lriutzel/.nix-profile/share/terminfo";
      WSLENV="TERMINFO_DIRS";
      XAUTHORITY="/home/lriutzel/.Xauthority";
    };

    home.username = settings.user.username;
    home.homeDirectory = "/home/${settings.user.username}";

    home.packages = with pkgs; lib.mkIf (nixosConfig.machine.sizeTarget > 0 ) [
      #unstable.neovim
      #(aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      imv # minimal image viewer

      libnotify # for notify-send

      iotop
      inetutils
      usbutils # alt busybox cope toybox

      nmap

      #playerctl??
      tealdeer # $tldr strace

      unzip # duh

      # darktile # alternative TTY to try out. GPU + go

      xdg-utils # for xdg-open

      bitwarden-cli

      python39Packages.youtube-dl # there is an alt youtube-dl-lite

      lftp

      units

    ] // lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) [
      pavucontrol # GUI volume source/sink manager
      zathura # PDF / Document viewer
      libreoffice # Office suite
      fractal # matrix client
      thunderbird-91 # Email client
      #firefox # Web browser
      tixati # bittorrent client
      mumble # voice chat application
      signal-desktop

      tor-browser-bundle-bin

      xfce.thunar
      #pantheon.elementary-files

      python39Packages.xdot # graphviz viewer
      graphviz

      # Spotify opensource utils?
      spotify-tui # spotifyd ui
      spotifyd # music player no ui
      # NonFree
      spotify
      zoom-us


      playerctl

      wireshark

      mindforger

      wineApps.winbox
      winetricks
      wineWowPackages.stable
    ];

    services = lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) {
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
