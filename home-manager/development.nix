{ pkgs, lib, nixosConfig, ... }:

let
  settings = import ../settings;
in {
  home.packages = with pkgs; lib.mkIf (nixosConfig.machine.sizeTarget > 1 ) [
    gdb
    hyperfine
    valgrind
    gitui
  ];

  home.file.".gdbinit".text = ''
    set disassembly-flavor intel
    set history save on
    set print pretty on
  '';

  programs.git = {
    enable = true;
    userName = settings.user.name;
    userEmail = settings.user.email;

    delta.enable = true;

    extraConfig = {
      init.defaultBranch = "master";
      core.editor = "nvim";
      #protocol.keybase.allow = "always";
      #credential.helper = "store --file ~/.git-credentials";
      #pull.rebase = "false";
    };

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
      ".#*"
      "*.pyc"
      "*.swo"
      "*.swp"
      ".DS_Store"
      ".settings.xml"
      ".gdb_history"
      ".direnv/"
    ];
  };

  services.lorri.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };
}
