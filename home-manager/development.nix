{ pkgs, lib, nixosConfig, ... }:

let
  inherit (lib) mkIf;
  settings = import ../settings;
  sizeTarget = nixosConfig.machine.sizeTarget;
  ifGraphical = sizeTarget > 1;
in {
  home.packages = with pkgs; mkIf ifGraphical [
    gdb # debugger
    hyperfine
    valgrind
    #rr # time traveling debugger # failed on unstable
    #allocscope # a memory tracking tool https://github.com/matt-kimball/allocscope
  ];

  home.file.".gdbinit".text = ''
    set disassembly-flavor intel
    set history save on
    set print pretty on
  '';

  # git tui
  programs.gitui.enable = true;

  programs.git = {
    enable = true;
    userName = settings.user.name;
    userEmail = settings.user.email;

    delta.enable = true;

    extraConfig = {
      init.defaultBranch = "master";
      color.ui = true;
      core.editor = "nvim";
      merge.conflictStyle = "diff3";
      merge.guitool = "nvimdiff";
      merge.tool = "vimdiff";
      mergetool.prompt = true;
      mergetool.vimdiff.cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";

      pull.ff = "only";
      pull.rebase = "true";
      push.default = "current";
      #push.autoSetupRemote = "current"; #broke `git push origin HEAD`
      branch.autoSetupRebase = "remote";
      #protocol.keybase.allow = "always";
      #credential.helper = "store --file ~/.git-credentials";
    };

    aliases = {
      # list commits in a tree
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      # list branches and their last commit time
      lb = "!git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf(\"  \\033[33m%s: \\033[37m %s\\033[0m\\n\", substr($2, 1, length($2)-1), $1)}'";
      # list all branches and their tracked remote
      tracked = "for-each-ref --format='%(refname:short) <- %(upstream:short)' refs/heads";
      # poke was used with gitea. Unsure what other uses this has
      poke = "!git ls-remote origin | grep -w refs/heads/poke && git push origin :poke || git push origin master:poke";
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
      git = "!exec git"; # accidentally run `git git ...`? This has your back
      root = "rev-parse --show-toplevel"; # show path of the root of repo
    };

    ignores = [
      # OS Specific
      "*~"
      ".#*"
      "*.pyc"
      "*.swo"
      "*.swp"
      ".DS_Store"
      ".settings.xml"
      ".gdb_history"
      ".direnv"

      # Archives
      "*.tar"
      "*.tar.gz"
      "*.7z"
      "*.zip"
    ];
  };

  services.lorri.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ""; # custom functions ect
    config = {
      global = {
        warn_timeout = "30s";
        strict_env = true;
      };
      whitelist = {
        prefix = [
          # Doesn't feel right to whitelist anything in my projects. I'll have
          # to review each one to make sure there isn't execution I dislike.
          #"$HOME/Projects/rust"
        ];
      };
    };
  };
}
