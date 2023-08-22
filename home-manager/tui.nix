{
  pkgs,
  config,
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) optionalString;
  settings = import ../settings;
in {
  imports = [
    ./base16.nix
  ];

  config = {
    home.sessionVariables = {
      # Share environment variables between WSL and Windows
      #TERMINFO_DIRS = "${config.home.homeDirectory}/.nix-profile/share/terminfo";
      #WSLENV="$TERMINFO_DIRS";

      # interups `nix store ping` and some ssh sessions when in 
      #   environment.sessionVariables
      # might need to be interactive only.
      LESS_TERMCAP_mb="$(tput bold; tput setaf 2)";
      LESS_TERMCAP_md="$(tput bold; tput setaf 3)";
      LESS_TERMCAP_me="$(tput sgr0)";
      LESS_TERMCAP_so="$(tput bold; tput setaf 3; tput setab 4)";
      LESS_TERMCAP_se="$(tput rmso; tput sgr0)";
      LESS_TERMCAP_us="$(tput smul; tput bold; tput setaf 2)";
      LESS_TERMCAP_ue="$(tput rmul; tput sgr0)";
      LESS_TERMCAP_mr="$(tput rev)";
      LESS_TERMCAP_mh="$(tput dim)";
      LESS_TERMCAP_ZN="$(tput ssubm)";
      LESS_TERMCAP_ZV="$(tput rsubm)";
      LESS_TERMCAP_ZO="$(tput ssupm)";
      LESS_TERMCAP_ZW="$(tput rsupm)";
    };

    programs = {
      bash = {
        enable = true;
        historyFile = "~/.local/state/bash/history";
        historyControl = [
          "ignoredups"
          "ignorespace"
        ];
        historyIgnore = ["l" "ll" "lll" "bg" "fg" "clear" "ls" "cd" "exit"];
        initExtra =
          ''
            source ${config.lib.base16.templateFile {name = "shell";}}
          ''
          + optionalString config.programs.starship.enable ''
            eval "$(starship init bash)"
          '';
        shellOptions = [
          "dirspell"
          "cdspell"
          "histappend"
          "cmdhist"
          "checkwinsize"
          "extglob"
          "globstar"
          "checkjobs"
        ];
      };

      htop.enable = true;

      readline = {
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
    };

    home.file."${config.xdg.configHome}/htop/htoprc".source = ./htoprc;

    home.packages = with pkgs; [
      # Debug / system info
      iotop
      inetutils
      usbutils # an alternative could be busybox cope toybox
      hwloc # can show hardware topo with lstopo
      #unzip # duh
      lftp

      # unar is HUGE at 930mb
      #unar # An archive unpacker program GUI & TUI
      units

      sad # tool to search and replace
      jless # json viewer
      tealdeer # $tldr strace
      nota # fancy cli calculator
      #bitwarden-cli
      python39Packages.youtube-dl # there is an alt youtube-dl-lite
      xdg-utils # for xdg-open
      xdg-user-dirs # command to get the path to Downloads/Pictures/ect
      #nur.repos.ambroisie.comma # like nix-shell but more convinient
      nixos-shell

      ## spreadsheet stuffs
      sc-im
      visidata

      # TUI to GUI helpers
      #dragon-drop # in unstable its maybe xdragon
      ## networking
      nethogs
      ngrep
      ## fast adds chromium
      #fast-cli # bandwidth test through fast.com
      nmap

      ## Audio
      playerctl # TUI

      # Fun
      asciiquarium # Fun aquarium animation
      cmatrix # Fun matrix animation
      cava # Console-based Audio Visualizer for Alsa

      # k8s
      k9s # Kubernetes CLI To Manage Your Clusters In Style
    ];
  };
}
