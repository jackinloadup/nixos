{ config, pkgs, nixosConfig, ... }:

let
  nvim-syntax-rsc-mikrotik = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/olejor/mikrotik/master/syntax/vim/rsc.vim";
    sha256 = "b32568b014864eb7399c900d82f8e2d921c5b7cc83cafd5525296a7acbdfc20e";
  };
in {
  home.file."${config.xdg.configHome}/nvim/syntax/rsc.vim".source = nvim-syntax-rsc-mikrotik;

  home.sessionVariables = {
    EDITOR = "nvim";
    NVIM_TUI_ENABLE_TRUE_COLOR = 1;
    NVIM_TUI_ENABLE_CURSOR_SHAPE = 2; # blink cursor maybe? https://github.com/neovim/neovim/pull/5977
  };

  home.packages = with pkgs; [
    rust-analyzer
    graphviz
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
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
      plenary-nvim
      nvim-dap

      # Rust
      rust-tools-nvim # To enable more of the features of rust-analyzer, such as inlay hints and more!

      # Language Server
      nvim-lspconfig # Collection of common configurations for the Nvim LSP client
      lsp_lines-nvim # Renders diagnostics using virtual lines on top of the real line of code

      nvim-cmp # Completion framework

      # Completion Sources
      cmp-nvim-lsp # LSP completion source for nvim-cmp
      cmp-vsnip # Snippet completion source for nvim-cmp
      cmp-path
      cmp-buffer

      # Snippet engine
      vim-vsnip

      # UI
      gruvbox-community # theme
      vim-gitgutter # git status in the gutter
      vim-airline # like starship for status line

      # Editor Features
      vim-surround
      indentLine # thin line at each indent level
      vim-fugitive # A Git wrapper so awesome, it should be illegal

      (nvim-treesitter.withPlugins (
        # The following plugins come from here
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/tools/parsing/tree-sitter/update.nix
        plugins: with plugins; [
          # from tree-sitter github org
          tree-sitter-html
          tree-sitter-css
          tree-sitter-bash
          tree-sitter-javascript
          tree-sitter-typescript
          tree-sitter-json
          tree-sitter-python
          tree-sitter-toml
          tree-sitter-rust
          tree-sitter-php

          # other repos
          tree-sitter-nix
          tree-sitter-make
          tree-sitter-markdown
          tree-sitter-lua
          tree-sitter-vim
          tree-sitter-yaml
          tree-sitter-dockerfile
          tree-sitter-scss
        ]
      ))
    ];

    extraConfig = ''

      ${builtins.readFile ./completion.vim}
      ${builtins.readFile ./folds.vim}
      ${builtins.readFile ./formatting.vim}
      ${builtins.readFile ./tags.vim}
      ${builtins.readFile ./user-interface.vim}


      "set diffopt=filler " Add vertical spaces to keep right and left aligned
      "set diffopt+=iwhite " Ignore whitespace changes (focus on code changes)
      "set encoding=utf-8 nobomb " BOM often causes trouble
      "set fillchars+=vert:\
      "set gdefault " By default add g flag to search/replace. Add g to toggle
      "set hidden " When a buffer is brought to foreground, remember undo history and marks
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
      "set scrolloff=3 " Start scrolling three lines before horizontal border of window
      "set shiftwidth=2 " The # of spaces for indenting
      "set shortmess=atI " Don't show the intro message when starting vim
      "set sidescrolloff=3 " Start scrolling three columns before vertical border of window
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
require'nvim-treesitter.configs'.setup {
  -- https://github.com/nvim-treesitter/nvim-treesitter

  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  -- ensure_installed = { 'bash', 'html', 'javascript', 'json', 'lua', 'python', 'toml', 'yaml', 'rust', 'vim', 'css', 'scss', 'nix', 'php' },
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing for "all"
  highlight = {
    enable = true,              -- false will disable the whole extension

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },  -- list of language that will be disabled

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  }
}

      require('rust-tools').setup({})

      -- require("lsp_lines").setup()
      -- -- Disable virtual_text since it's redundant due to lsp_lines.
      -- vim.diagnostic.config({
      --   virtual_text = false,
      -- })
EOF

      source ${config.xdg.configHome}/nvim/syntax/rsc.vim

    '';
  };
}
