{ pkgs, config, lib, nixosConfig, ... }:

with lib;
let
  settings = import ../settings;
  ifTui = if (nixosConfig.machine.sizeTarget > 0) then true else false;
  ifGraphical = if (nixosConfig.machine.sizeTarget > 1) then true else false;
in {
  imports = [
    ./base16.nix
  ];

  config = {
    home.sessionVariables = {
      TERMINFO_DIRS="${config.home.homeDirectory}/.nix-profile/share/terminfo";
      # Share environment variables between WSL and Windows
      #WSLENV="$TERMINFO_DIRS";
    };

    programs = {
      bash = {
        enable = true;
        initExtra = ''
          source ${config.lib.base16.templateFile { name = "shell"; }}
          '' + optionals ifTui ''
          eval "$(starship init bash)"
          '';
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

    home.packages = with pkgs; []
      ++ lib.optionals ifTui [
    ]
    ++ lib.optionals ifGraphical [
      # Debug / system info
      iotop
      inetutils
      usbutils # an alternative could be busybox cope toybox
      #unzip # duh
      lftp

      # unar is HUGE at 930mb
      #unar # An archive unpacker program GUI & TUI
      units

      jless # json viewer
      tealdeer # $tldr strace
      nota # fancy cli calculator
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
      playerctl # TUI

      # Fun
      asciiquarium # Fun aquarium animation
      cmatrix # Fun matrix animation
    ];
  };
}
