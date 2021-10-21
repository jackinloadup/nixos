{ lib, pkgs, config, ... }:

with lib;
{
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
      eval "$(starship init zsh)"

      bindkey '^R' history-incremental-pattern-search-backward
      bindkey '^F' history-incremental-pattern-search-forward
    '';
  };

  home-manager.users.lriutzel.programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;

      #zsh-autoenv.enable = false;

      history = rec {
        size = 100000;
        save = size;
        path = "$HOME/.local/share/zsh/history";
        ignorePatterns = [ "rm *" "pkill *" ];
        expireDuplicatesFirst = true;
      };

    };


    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        format = concatStrings [
          "$time"
          "$character"
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
      };
    };
  };
  users.users.lriutzel.shell = pkgs.zsh;
}
