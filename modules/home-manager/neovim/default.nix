{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  nvim-syntax-rsc-mikrotik = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/olejor/mikrotik/master/syntax/vim/rsc.vim";
    sha256 = "b32568b014864eb7399c900d82f8e2d921c5b7cc83cafd5525296a7acbdfc20e";
  };
in
  mkIf config.programs.neovim.enable {
    home.file."${config.xdg.configHome}/nvim/syntax/rsc.vim".source = nvim-syntax-rsc-mikrotik;

    home.sessionVariables = {
      EDITOR = "nvim";
      NVIM_TUI_ENABLE_TRUE_COLOR = 1;
    };

    home.packages = [
      pkgs.graphviz

      # Language Servers
      pkgs.rnix-lsp # Nix
      pkgs.rust-analyzer # Rust
      pkgs.sumneko-lua-language-server # Lua
    ];

    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = false;
      withRuby = false;

      # not needed if we are not compiling tree-sitter grammers
      #extraPackages = with pkgs; [
      #  gcc
      #];

      plugins = with pkgs.vimPlugins; [
        # Syntax
        vim-nix
        #vim-go # ~800mb
        #rust-vim
        plenary-nvim # All the lua functions I don't want to write twice

        nvim-dap # Debug Adapter Protocol client

        # UI
        gruvbox-community # theme
        vim-gitgutter # git status in the gutter
        vim-airline # like starship for status line


        # tmux
        (import ./vim-tmux-navigator.nix {pkgs = pkgs;}) #

        # Editor Features
        (import ./indentline.nix {pkgs = pkgs;}) # vscode-like pictograms to neovim built-in lsp
        vim-fugitive # A Git wrapper so awesome, it should be illegal
        (import ./git-worktree.nix {pkgs = pkgs;}) # Navigate in git worktrees easily
        #vim-surround  # need to configure and don't use yet

        (import ./lspkind-nvim.nix {pkgs = pkgs;}) # vscode-like pictograms to neovim built-in lsp
        (import ./nvim-dap-ui.nix {pkgs = pkgs;})
        (import ./nvim-treesitter.nix {pkgs = pkgs;})
        (import ./lsp_lines.nix {pkgs = pkgs;}) # Renders diagnostics using virtual lines on top of the real line of code

        # Rust
        (import ./rust-tools-nvim.nix {pkgs = pkgs;}) # Enable more of the features of rust-analyzer, such as inlay hints and more!

        # Language Server
        (import ./nvim-lspconfig.nix {pkgs = pkgs;}) # Collection of common configurations for the Nvim LSP client

        (import ./nvim-cmp.nix {pkgs = pkgs;}) # Completion framework
        # Completion Sources
        cmp-nvim-lsp # LSP completion source for nvim-cmp
        cmp-nvim-lua # lua API source
        cmp_luasnip # Snippet Engine completion source
        cmp-path
        cmp-buffer

        (import ./telescope-nvim.nix {pkgs = pkgs;}) # Find, Filter, Preview, Pick
        (import ./luasnip.nix {pkgs = pkgs;}) # Snippet engine
        {
          plugin = pkgs.vimPlugins.copilot-cmp;
          type = "lua";
          config = ''
            require("copilot_cmp").setup()
          '';
        }
        (import ./copilot.nix {pkgs = pkgs;}) # github copilot requires nodejs
      ];

      extraConfig = ''

              ${builtins.readFile ./completion.vim}
              ${builtins.readFile ./folds.vim}
              ${builtins.readFile ./formatting.vim}
              ${builtins.readFile ./tags.vim}
              ${builtins.readFile ./user-interface.vim}


              let mapleader = ";"
              set clipboard+=unnamedplus
              " enable spellchecking
              set spell
              set spelllang=en_us
              "set diffopt=filler " Add vertical spaces to keep right and left aligned
              "set diffopt+=iwhite " Ignore whitespace changes (focus on code changes)
              "set encoding=utf-8 nobomb " BOM often causes trouble
              "set fillchars+=vert:\
              "set gdefault " By default add g flag to search/replace. Add g to toggle
              "set lispwords+=defroutes " Compojure
              "set lispwords+=defpartial,defpage " Noir core
              "set lispwords+=defaction,deffilter,defview,defsection " Ciste core
              "set lispwords+=describe,it " Speclj TDD/BDD
              "set magic " Enable extended regexes
              "set noerrorbells " Disable error bells
              "set nojoinspaces " Only insert single space after a '.', '?' and '!' with a join command
              "set noshowmode " Don't show the current mode (lightline.vim takes care of us)
              "set nostartofline " Don't reset cursor to start of line when moving around
              "set ofu=syntaxcomplete#Complete " Set omni-completion method
              "set report=0 " Show all changes
              "set ruler " Show the cursor position
              "set shiftwidth=2 " The # of spaces for indenting
              "set shortmess=atI " Don't show the intro message when starting vim
              "set softtabstop=2 " Tab key results in 2 spaces
              "set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll
              "set switchbuf=""
              "set undofile " Persistent Undo
              "set viminfo='9999,s512,h " Restore marks are remembered for 9999 files, registers up to 512Kb are remembered, disable hlsearch on start
              "set visualbell " Use visual bell instead of audible bell (annnnnoying)
              "set wildchar=<TAB> " Character for CLI expansion (TAB-completion)
              "set wildignore+=.DS_Store
              "set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
              "set wildignore+=*/bower_components/*,*/node_modules/*
              "set wildignore+=*/smarty/*,*/vendor/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*,*/doc/*,*/source_maps/*,*/dist/*


              lua <<EOF
        EOF

              source ${config.xdg.configHome}/nvim/syntax/rsc.vim

      '';
    };
  }
