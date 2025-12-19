{
  pkgs,
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) mkIf;
  settings = import ../../settings;
  sizeTarget = nixosConfig.machine.sizeTarget;
  ifGraphical = sizeTarget > 1;
in {
  # TO REVIEW https://www.brendangregg.com/blog/2024-03-24/linux-crisis-tools.html
  home.packages = mkIf ifGraphical [
      pkgs.gdb # debugger
      pkgs.hyperfine
      pkgs.valgrind
      #pkgs.rr # time traveling debugger # failed on unstable
      #pkgs.allocscope # a memory tracking tool https://github.com/matt-kimball/allocscope
      #pkgs.unityhub # Game development tool
      pkgs.nurl # Generate Nix fetcher calls from repository URLs
      # zeal-qt6 # offline documentation browser
      pkgs.fx # command-line JSON viewer
      pkgs.fq # for binary formats - tool, language and decoders for working with binary and text formats
      #pkgs.kubediff

      #python39Packages.xdot # graphviz viewer # erro with pycairio compile
      pkgs.graphviz
      pkgs.rustscan # faster than nmap port scanner

      #    # TUI tools but loading if graphical
      #    mqttui # mqtt tui

      #    # markdown tools
      #    mdcat # tui viewer
      #    mdp # markdown presentation
      #    mdr # tui viewer
      #    # mdv # tui viewer not in nixpkgs yet
      #pkgs.mr # multi repo
    ];

  home.file.".gdbinit".text = ''
    set disassembly-flavor intel
    set history save on
    set print pretty on
  '';

  # git tui
  programs.gitui.enable = true;
  programs.nixvim.enable = true;

  programs.delta.enable = true; # Whether to enable delta, a syntax highlighter for git diffs.

  programs.git = {
    enable = true;


    settings = {
      user = {
        name = settings.user.name;
        email = settings.user.email;
      };

      alias = {
        viz = "log --all --decorate --oneline --graph";
        # list commits in a tree
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        # list branches and their last commit time
        lb = "!git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf(\"  \\033[33m%s: \\033[37m %s\\033[0m\\n\", substr($2, 1, length($2)-1), $1)}'";
        # list all branches and their tracked remote
        tracked = "for-each-ref --format='%(refname:short) <- %(upstream:short)' refs/heads";
        # poke was used with gitea. Unsure what other uses this has
        poke = "!git ls-remote origin | grep -w refs/heads/poke && git push origin :poke || git push origin master:poke";

        tagsbydate = "for-each-ref --sort=-taggerdate --format='%(refname:short)' refs/tags";
        #previoustag = "!sh -c 'git tagsbydate --count 2 | cut -f2 | sed -n 2p'";
        previoustag = "git describe --tags --abbrev=0";
        #lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
        markdownlog = "log --color --pretty=format:'* %s `%Cred%h%Creset` - %C(bold blue)[%an](mailto:%ae)%Creset' --abbrev-commit --dense --no-merges --reverse";
        # Can't get sed to work. Have to pipe through to remove empty <details>
        # tags
        #ghlog2 = "!git log --color --pretty=format:'%s `%Cred%h%Creset` - %C(bold blue)[%an](mailto:%ae)%Creset<details>%b</details>' --abbrev-commit --dense --no-merges --reverse $@ | sed \"s/<[^\/][^<>]*> *<\/[^<>]*>//g\" #";
        #ghlog = "!f() { git log --color --pretty=format:'%s `%Cred%h%Creset` - %C(bold blue)[%an](mailto:%ae)%Creset<details>%b</details>' --abbrev-commit --dense --no-merges --reverse $@ | sed 's/<[^\/][^<>]*> *<\/[^<>]*>//g' #; }; f #";
        releasenotes = "!sh -c 'git markdownlog ...`git previoustag`'";
        done = "push origin HEAD";
        wip = "!f() { git add . && git commit -m 'Work in progress'; }; f";
        diff-words = "diff --color-words='[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+'";

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
        debug = "!GIT_TRACE=1 git"; # clever way to debug git stuff ex: git debug ghlog
        root = "rev-parse --show-toplevel"; # show path of the root of repo
        cdroot = "!cd `git root`"; # show path of the root of repo
      };

      extraConfig = {
        color.ui = true;
        core.editor = "nvim";
        #credential.helper = "store --file ~/.git-credentials";
        credential.helper = "store";
        merge.conflictStyle = "diff3";
        merge.guitool = "nvimdiff";
        merge.tool = "vimdiff";
        mergetool.prompt = true;
        "mergetool \"vimdiff\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";

        pull.ff = "only";
        pull.rebase = "true";
        push.default = "current";
        #push.autoSetupRemote = "current"; #broke `git push origin HEAD`
        branch.autoSetupRebase = "remote";
        #protocol.keybase.allow = "always";
        #credential.helper = "store --file ~/.git-credentials";
        rebase.autosquash = true;
        "url \"git@github.com:\"".insteadOf = "https://github.com/";
      };

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
    # current layout fn makes hashed name. human readable is also possible
    # https://github.com/direnv/direnv/wiki/Customizing-cache-location
    stdlib = ''
      # Two things to know:
      # * `direnv_layour_dir` is called once for every {.direnvrc,.envrc} sourced
      # * The indicator for a different direnv file being sourced is a different $PWD value
      # This means we can hash $PWD to get a fully unique cache path for any given environment

      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
      	echo "''${direnv_layout_dirs[$PWD]:=$(
      		echo -n "$XDG_CACHE_HOME"/direnv/layouts/
      		echo -n "$PWD" | sha1sum | cut -d ' ' -f 1
      	)}"
      }
    ''; # custom functions ect
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

  programs.k9s = {
    settings = {
      skin = "skin"; # use stylix skin
      # following doesn't work for some reason
      #logoless = true;
      #noIcons = false;
      #enableMouse = true;
    };
  };

  programs.lazydocker = {
    enable = nixosConfig.virtualisation.docker.enable;
    settings = {
      # makes diagnosing why you can't connect to container impossible
      #gui.returnImmediately = true;
    };
  };
}
