{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.machine;
  settings = import ../../settings;
in {
  config = mkIf cfg.tui {
    environment.systemPackages = with pkgs; [
      tmux
      #tmux-cssh;
    ];

    programs.tmux = {
      enable = true; # Enables system-wide configuration
      terminal = "tmux-256color";
      newSession = true;
      baseIndex = 1;
      keyMode = "emacs"; # default
      aggressiveResize = true;
      resizeAmount = 10;
      # the following comment goes into the extra config but it broke
      # source ${config.lib.base16.templateFile { name="tmux"; }}
      extraConfig = ''
        set -ga terminal-overrides ',*256col*:Tc'
        set-option -g mouse on

        # set the message display-time to 4s
        set-option -g display-time 4000

        # C-b + C-b will go to the last window
        bind-key C-b last-window

        bind-key -T copy-mode-vi v send-keys -X begin-selection

        # don't rename windows automatically
        set-option -g allow-rename off

        # vim window reizing
        bind < resize-pane -L 10
        bind > resize-pane -R 10
        bind - resize-pane -D 10
        bind + resize-pane -U 10

        set-window-option -g mode-keys vi
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # same directory as the current window
        bind-key c new-window -c "#{pane_current_path}"
        bind-key % split-window -h -c "#{pane_current_path}"
        bind-key '"' split-window -v -c "#{pane_current_path}"

        # THEME
        # Status Bar
        set -g status-bg black
        set -g status-fg white
        set -g status-interval 60
        set -g status-left '#[fg=green]#T>'
        set -g status-left-length 30
        set -g status-right-length 75

        # uncomment for screensaver. be sure to have asciiquarium installed
        #set-option -g lock-command asciiquarium
        #set-option -g lock-after-time 180
      '';
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
      ];
      #plugins = with pkgs.tmuxPlugins; [
      #  {
      #    plugin = pain-control;
      #    extraConfig = "set -g @plugin 'tmux-plugins/tmux-pain-control'";
      #  }
      #  {
      #    plugin = sensible;
      #    extraConfig = "set -g @plugin 'tmux-plugins/tmux-sensible'";
      #  }
      #  {
      #    plugin = sessionist;
      #    extraConfig = "set -g @plugin 'tmux-plugins/tmux-sessionist'";
      #  }
      #  {
      #    plugin = yank;
      #    extraConfig = "set -g @plugin 'tmux-plugins/tmux-yank'";
      #  }
      #  {
      #    plugin = tmux-colors-solarized;
      #    extraConfig = ''
      #      set -g @plugin 'seebi/tmux-colors-solarized'
      #      set -g @colors-solarized 'dark'
      #    '';
      #  }
      #];
    };
  };
}
