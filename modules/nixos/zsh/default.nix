{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  ifTui = config.machine.sizeTarget > 0;
  users = config.machine.users;
  interactive = ''
      source ${config.lib.base16.templateFile {name = "shell";}}

      bindkey '^a' beginning-of-line

      bindkey '^R' history-incremental-pattern-search-backward
      bindkey '^F' history-incremental-pattern-search-forward

      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line

    #  # Change cursor shape for different vi modes.
    #  function zle-keymap-select {
    #    if [[ ''${KEYMAP} == vicmd ]] ||
    #       [[ $1 = 'block' ]]; then
    #      echo -ne '\e[1 q'
    #    elif [[ ''${KEYMAP} == main ]] ||
    #         [[ ''${KEYMAP} == viins ]] ||
    #         [[ ''${KEYMAP} = '\' ]] ||
    #         [[ $1 = 'beam' ]]; then
    #      echo -ne '\e[5 q'
    #    fi
    #  }
    #  zle -N zle-keymap-select
    #  zle-line-init() {
    #      zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    #      echo -ne "\e[5 q"
    #  }
    #  zle -N zle-line-init
    #  echo -ne '\e[5 q' # Use beam shape cursor on startup.
    #  preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

      # Use lf to switch directories and bind it to ctrl-o
      lfcd () {
          tmp="$(mktemp)"
          lf -last-dir-path="$tmp" "$@"
          if [ -f "$tmp" ]; then
              dir="$(cat "$tmp")"
              rm -f "$tmp"
              [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
          fi
      }
      bindkey -s '^o' 'lfcd\n'

      bindkey '^R' history-incremental-pattern-search-backward
      bindkey '^F' history-incremental-pattern-search-forward

      # C-z to toggle current process (background/foreground)
      fancy-ctrl-z () {
        if [[ $#BUFFER -eq 0 ]]; then
          BUFFER="fg"
          zle accept-line
        else
          zle push-input
          zle clear-screen
        fi
      }
      zle -N fancy-ctrl-z
      bindkey '^Z' fancy-ctrl-z
  '';
in
  mkIf ifTui {
    # might break current auto start sway script
    #users.defaultUserShell = "${pkgs.zsh}/bin/zsh";

    #environment.systemPackages = with pkgs; [
    #  starship
    #];

    environment.pathsToLink = [ "/share/zsh" ];
    environment.shells = [ pkgs.zsh ];

    programs.zsh = {
      enable = true;

      syntaxHighlighting = {
        enable = false;
        highlighters = [
          "main"
          "brackets"
          "root"
          #"pattern"
          #"line"
        ];
      };
      autosuggestions.enable = false; #for systemwide?
      autosuggestions.extraConfig.ZSH_AUTOSUGGEST_USE_ASYNC = "y";

      setOptions = [
        "noautomenu"
        "nomenucomplete"
        "AUTO_CD"
        "BANG_HIST"
        "EXTENDED_HISTORY"
        "HIST_EXPIRE_DUPS_FIRST"
        "HIST_FIND_NO_DUPS"
        "HIST_IGNORE_ALL_DUPS"
        "HIST_IGNORE_DUPS"
        "HIST_IGNORE_SPACE"
        "HIST_REDUCE_BLANKS"
        "HIST_SAVE_NO_DUPS"
        "INC_APPEND_HISTORY"
        "SHARE_HISTORY"
      ];

      interactiveShellInit = interactive;
    };
  }
