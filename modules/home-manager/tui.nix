{
  pkgs,
  config,
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) optionalString;
  settings = import ../../settings;
in {
  imports = [
    ./base16.nix
  ];

  config = {
    home.sessionVariables = {
      # Share environment variables between WSL and Windows
      #TERMINFO_DIRS = "${config.home.homeDirectory}/.nix-profile/share/terminfo";
      #WSLENV="$TERMINFO_DIRS";
    };

    programs = {
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
      lftp # ftp client
      terminal-colors # print all the terminal colors

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
      bfs # breadth-first version of the UNIX find command. might be faster than fd?
      broot # tree directory viewer
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
      nms # https://github.com/bartobri/no-more-secrets
      cava # Console-based Audio Visualizer for Alsa
      nsnake # snake game
      terminal-parrot # parrot in your terminal

      # k8s
      k9s # Kubernetes CLI To Manage Your Clusters In Style
    ];
  };
}
