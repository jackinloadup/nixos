{ lib, pkgs, config, ... }:

{
  home-manager.users.lriutzel.programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;

      history = rec {
        size = 100000;
        save = size;
        path = "$HOME/.local/share/zsh/history";
      };
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
      };
    };
  };
  users.users.lriutzel.shell = pkgs.zsh;
}
