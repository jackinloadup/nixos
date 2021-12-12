{ lib, pkgs, config, ... }:

with lib;
let
  users = config.machine.users;
in {
  # might break current auto start sway script
  #users.defaultUserShell = pkgs.zsh; # haven't tried

  environment.systemPackages = with pkgs; [
    starship
  ];

  programs.zsh = {
    enable = true;

    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "root"
      ];
    };
    autosuggestions.enable = false; #for systemwide?
    interactiveShellInit = ''
      source ${config.lib.base16.templateFile { name = "shell"; }}

      bindkey '^R' history-incremental-pattern-search-backward
      bindkey '^F' history-incremental-pattern-search-forward

      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line

      # Change cursor shape for different vi modes.
      function zle-keymap-select {
        if [[ ''${KEYMAP} == vicmd ]] ||
           [[ $1 = 'block' ]]; then
          echo -ne '\e[1 q'
        elif [[ ''${KEYMAP} == main ]] ||
             [[ ''${KEYMAP} == viins ]] ||
             [[ ''${KEYMAP} = '\' ]] ||
             [[ $1 = 'beam' ]]; then
          echo -ne '\e[5 q'
        fi
      }
      zle -N zle-keymap-select
      zle-line-init() {
          zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
          echo -ne "\e[5 q"
      }
      zle -N zle-line-init
      echo -ne '\e[5 q' # Use beam shape cursor on startup.
      preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

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
    '';
  };
#} // (builtins.concatMap (name: {
} // mkIf (builtins.elem "lriutzel" config.machine.users) {
  #users.users.${name}.shell = pkgs.zsh;

  #home-manager.users.${name}.programs = {
  users.users.lriutzel.shell = pkgs.zsh;

  home-manager.users.lriutzel.programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;

      initExtra = ''
        function set_win_title(){
          echo -ne "\033]0; $(basename "$PWD") \007"
        }
        precmd_functions+=(set_win_title)

        eval "$(starship init zsh)"
      '' + config.programs.zsh.interactiveShellInit;

      shellAliases = config.environment.shellAliases;

      loginExtra = ''
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

      shellGlobalAliases = {
        UUID = "$(uuidgen | tr -d \\n)";
        G = "| grep";
        L = "| less";
        "@noerr" = "2> /dev/null";
        "@noboth" = "&> /dev/null";
        "@errtostd" = "2&>1";
      };

      dirHashes = {
        docs  = "$HOME/Documents";
        vids  = "$HOME/Videos";
        dl    = "$HOME/Downloads";
        p     = "$HOME/Projects";
      };

      #zsh-autoenv.enable = false;

      history = rec {
        size = 100000;
        save = size;
        path = "$HOME/.local/share/zsh/history";
        #path = "${config.xdg.dataHome}/zsh/history"; # variable isn't available outside HM?
        ignorePatterns = [
          "rm *"
          "pkill *"
          "lscd"
        ];
        expireDuplicatesFirst = true;
        ignoreSpace = true;
      };

      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.4.0";
            sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
          };
        }
      ];
    };

    starship = {
      enable = true;
      package = pkgs.unstable.starship;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        format = concatStrings [
          "$time"
          "$username"
          "$hostname"
          "$character"
        ];
        right_format = concatStrings [
          "$all"
        ];
        scan_timeout = 10;
        add_newline = false;
        line_break = {
          disabled = true;
        };
        time = {
          disabled = false;
          time_format = "%l:%M%p";
          utc_time_offset = "-5";
          format = "$time($style) ";
        };
        username = {
          disabled = false;
        };
      };
    };
  };
}
#}) [ "lriutzel" ])
