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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      #unstable.tree-sitter
      rnix-lsp
      gcc
    ];

    plugins = with pkgs.vimPlugins; [
      # Syntax
      vim-nix
      #vim-go # ~800mb
      rust-vim

      # Language Server
      nvim-lspconfig

      # UI
      gruvbox-community
      vim-gitgutter # git status in the gutter
      vim-airline # like starship for status line
      nvim-treesitter

      # Editor Features
      vim-surround
      indentLine # thin line at each indent level
      vim-fugitive # A Git wrapper so awesome, it should be illegal
    ];

    extraConfig = ''
      " set background to be terminals
      highlight Normal guibg=none

      "" Set some junk {{{
      "set completeopt-=preview " Disable scratch buffer for completion preview
      set cursorline " Highlight current line
      "set diffopt=filler " Add vertical spaces to keep right and left aligned
      "set diffopt+=iwhite " Ignore whitespace changes (focus on code changes)
      "set encoding=utf-8 nobomb " BOM often causes trouble
      set expandtab " Expand tabs to spaces
      set relativenumber " Relative line numbers
      "set fillchars+=vert:\
      "set foldcolumn=0 " Column to show folds
      "set foldenable " Enable folding
      "set foldlevel=5 " Open all folds by default
      "set foldmethod=syntax " Syntax are used to specify folds
      "set foldminlines=0 " Allow folding single lines
      "set foldnestmax=5 " Set max fold nesting level
      "set formatoptions=
      "set formatoptions+=c " Format comments
      "set formatoptions+=r " Continue comments by default
      "set formatoptions+=o " Make comment when using o or O from comment line
      "set formatoptions+=q " Format comments with gq
      "set formatoptions+=n " Recognize numbered lists
      "set formatoptions+=2 " Use indent from 2nd line of a paragraph
      "set formatoptions+=l " Don't break lines that are already long
      "set formatoptions+=1 " Break before 1-letter words
      "set gdefault " By default add g flag to search/replace. Add g to toggle
      "set hidden " When a buffer is brought to foreground, remember undo history and marks
      set ignorecase " Ignore case of searches
      "set lispwords+=defroutes " Compojure
      "set lispwords+=defpartial,defpage " Noir core
      "set lispwords+=defaction,deffilter,defview,defsection " Ciste core
      "set lispwords+=describe,it " Speclj TDD/BDD
      if has("multi_byte")
              set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽
              "set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽,space:·
      else
              set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%
              "set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%,space:·
      endif
      set list
      "set lcs+=space:·
      "set magic " Enable extended regexes
      set mouse=a " Enable the mouse
      "set noerrorbells " Disable error bells
      "set nojoinspaces " Only insert single space after a '.', '?' and '!' with a join command
      "set noshowmode " Don't show the current mode (lightline.vim takes care of us)
      "set nostartofline " Don't reset cursor to start of line when moving around
      set nowrap " Do not wrap lines
      set number " Enable line numbers
      "set ofu=syntaxcomplete#Complete " Set omni-completion method
      "set report=0 " Show all changes
      "set ruler " Show the cursor position
      "set scrolloff=3 " Start scrolling three lines before horizontal border of window
      "set shiftwidth=2 " The # of spaces for indenting
      "set shortmess=atI " Don't show the intro message when starting vim
      "set sidescrolloff=3 " Start scrolling three columns before vertical border of window
      set smartcase " Ignore 'ignorecase' if search patter contains uppercase characters
      "set softtabstop=2 " Tab key results in 2 spaces
      "set splitbelow " New window goes below
      "set splitright " New windows goes right
      "set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll
      "set switchbuf=""
      "set title " Show the filename in the window titlebar
      " https://stackoverflow.com/questions/62702766/termguicolors-in-vim-makes-everything-black-and-white#62703167
      set termguicolors " Render the colors correctly. Enable 24-bit true colors
      "set undofile " Persistent Undo
      "set viminfo='9999,s512,h " Restore marks are remembered for 9999 files, registers up to 512Kb are remembered, disable hlsearch on start
      "set visualbell " Use visual bell instead of audible bell (annnnnoying)
      "set wildchar=<TAB> " Character for CLI expansion (TAB-completion)
      "set wildignore+=.DS_Store
      "set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
      "set wildignore+=*/bower_components/*,*/node_modules/*
      "set wildignore+=*/smarty/*,*/vendor/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*,*/doc/*,*/source_maps/*,*/dist/*
      "set winminheight=0 " Allow splits to be reduced to a single line
      set wrapscan " Searches wrap around end of file
      "" }}}

       syntax on
      " review gruvbox settings later for 256 color ect
      " https://github.com/gruvbox-community/gruvbox/wiki/Terminal-specific
      colorscheme gruvbox
      "let g:context_nvim_no_redraw = 1
      set background=dark

      let g:airline_powerline_fonts = 1

      lua <<EOF
require'nvim-treesitter.configs'.setup {
      ensure_installed = {
      'bash', 'html', 'javascript', 'json', 'lua', 'python', 'toml', 'yaml', 'rust', 'vim', 'css', 'scss', 'nix', 'php'
      }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

      source ${config.xdg.configHome}/nvim/syntax/rsc.vim
    '';
  };
}
