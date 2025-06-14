{
  lib,
  config,
  pkgs,
  nixosConfig,
  ...
}: {
  config = {
    programs.nixvim = {

      viAlias = true;
      vimAlias = true;
      defaultEditor = true;

      autoCmd = [
        {
          event = "VimEnter";
          command = "set nofoldenable";
          desc = "Unfold All";
        }
        {
          event = "BufWrite";
          command = "%s/\\s\\+$//e";
          desc = "Remove Whitespaces";
        }
        {
          event = "FileType";
          pattern = [ "markdown" "org" "norg" ];
          command = "setlocal conceallevel=2";
          desc = "Conceal Syntax Attribute";
        }
        {
          event = "FileType";
          pattern = [ "markdown" "org" "norg" ];
          command = "setlocal spell spelllang=en";
          desc = "Spell Checking";
        }
        {
          event = "FileType";
          pattern = [ "markdown" "org" "norg" ];
          command = ":TableModeEnable";
          desc = "Table Mode";
        }
        {
          event = "FileType";
          pattern = [ "markdown" ];
          command = "setlocal scrolloff=30";
          desc = "Fixed cursor location on markdown (for preview)";
        }
      ];


      opts = {
        hidden = true;
        shiftwidth = 2;
        tabstop = 2;
        softtabstop = 2;
        autoindent = true;
        sidescroll = 40;
        pumheight = 15;
        fileencoding = "utf-8";
        swapfile = false;
        timeoutlen = 2500;
        conceallevel = 3;


        ## Right Column
        relativenumber = true; # Relative line numbers
        number = true; # Enable line numbers

        ## Scrolling
        sidescrolloff = 3; # Start scrolling three columns before vertical border of window
        scrolloff = 3; # Start scrolling three lines before horizontal border of window

        ## Buffer
        #syntax on
        cursorline = true; # Highlight current line
        wrap = false; # Do not wrap lines
        list = true; # Show tabs and spaces via listchars
        #if has(#multi_byte#)
        #        set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽
        #        #set listchars=eol:¶,tab:˾˾,trail:˽,extends:↦,precedes:↤,nbsp:˽,space:·
        #else
        #        set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%
        #        #set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<,nbsp:%,space:·
        #endif

        ## Splits
        ## Open new split panes to right and bottom, which feels more natural
        splitbelow = true; # New window goes below
        splitright = true; # New windows goes right
        winminheight = 0; # Allow splits to be reduced to a single line

        ## Wildmenu - commandline completion menu
        wildmenu = true;
        wildmode = "longest:full,full";

        ## Make pane navigation available in one keystroke
        #nnoremap <C-J> <C-W><C-J>
        #nnoremap <C-K> <C-W><C-K>
        #nnoremap <C-L> <C-W><C-L>
        #nnoremap <C-H> <C-W><C-H>
        #
        ## Center cursor on screen when moving half pages
        #nnoremap <C-d> <C-d>zz
        #nnoremap <C-u> <C-u>zz
        #
        ## Center cursor on screen when searching forward/backward
        #nnoremap n nzzzv
        #nnoremap N Nzzzv
        #
        #
        ## :help splits
        ##
        ##  Resizing splits
        ##
        ## Vim’s defaults are useful for changing split shapes:
        ##
        ## #Max out the height of the current split
        ## ctrl + w _
        ##
        ## #Max out the width of the current split
        ## ctrl + w |
        ##
        ## #Normalize all split sizes, which is very handy when resizing terminal
        ## ctrl + w =
        ##
        ## More split manipulation
        ##
        ## #Swap top/bottom or left/right split
        ## Ctrl+W R
        ##
        ## #Break out current window into a new tabview
        ## Ctrl+W T
        ##
        ## #Close every window in the current tabview but the current one
        ## Ctrl+W o

        ##################
        # User Interface
        ##################

        ##################
        # Formatting
        ##################
        textwidth = 80; # A longer line will be broken after white space to get this width
        expandtab = true; # Expand tabs to spaces

        ## :help fo-table
        #formatoptions=
        #formatoptions+=c # Format comments
        #formatoptions+=r # Continue comments by default
        #formatoptions+=o # Make comment when using o or O from comment line
        #formatoptions+=/ # Used with 'o' dont make new comment if the comment doesn't start the line
        #formatoptions+=q # Format comments with gq
        #formatoptions+=n # Recognize numbered lists
        #formatoptions+=2 # Use indent from 2nd line of a paragraph
        #formatoptions+=l # Don't break lines that are already long
        #formatoptions+=1 # Break before 1-letter words
        #formatoptions+=j # Where it makes sense, remove a comment leader when joining lines

        formatexpr = "v:lua.vim.lsp.formatexpr()";


        ##################
        # Completion
        ##################
        # Set completeopt to have a better completion experience
        # :help completeopt
        # menuone: popup even when there's only one match
        # noinsert: Do not insert text until a selection is made
        # noselect: Do not select, force user to select one from the menu
        completeopt = ["menu" "menuone" "noselect"];
        #
        # Avoid showing extra messages when using completion
        # don't give |ins-completion-menu| messages.  For example,
        #  "-- XXX completion (YYY)", "match 1 of 2", "The only match",
        #"  "Pattern not found", "Back at original", etc.
        #shortmess+=c

        ##################
        # Searching
        ##################
        ignorecase = true; # Ignore case of searches
        smartcase = true; # Ignore 'ignorecase' if search patter contains uppercase characters
        wrapscan = true; # Searches wrap around end of file

        # :help foldenable
        foldenable = true; # Enable folding
        #foldcolumn=0; # Column to show folds
        foldlevel = 2; # Folds with a higher level will be closed
        #foldmethod=syntax; # Syntax are used to specify folds
        foldminlines = 5; # Allow folding single lines
        foldnestmax = 2; # max fold nesting level
        foldmethod = "expr";
        foldexpr = "nvim_treesitter#foldexpr()";

        ##################
        # Spell Checking
        ##################
        spell = true;
        spelllang = "en_us";
      };

      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };

      colorschemes.gruvbox.enable = true;
      #colorschemes.onedark = {
      #  enable = true;
      #  package = pkgs.vimPlugins.onedarkpro-nvim;
      #};

      globals = {
        mapleader = ";";
        maplocalleader = ";";
      };

      match = {
        ExtraWhitespace = "\\s\\+$";
      };

      plugins = {
        barbar.enable = true;

        #cmp-treesitter.enable = true;
        #cmp-path.enable = true;
        #cmp-spell.enable = true;
        #cmp-nvim-lua.enable = true;
        ##cmp-nvim-lsp.enable = true;
        #cmp_luasnip.enable = true;
        ##cmp-dap.enable = true; # not sure how dap is integrated and used

        #copilot-cmp.enable = true;
        #cmp-ai.enable = true;
        comment.enable = true;

        fugitive.enable = true;
        gitgutter.enable = true;

        indent-blankline = {
          enable = true;
          settings.scope.enabled = true;
        };

        lastplace.enable = true;
        lightline.enable = true;
        lsp-lines.enable = true;

        lsp = {
          enable = true;
          servers = {
            nixd.enable = true;
            rust-analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            lua-ls.enable = true;
            tsserver.enable = true; # typescript
            html.enable = true;
            cssls.enable = true;
            pyright.enable = true;
          };
        };

        lualine.enable = true;
        markdown-preview.enable = true;

        neo-tree = {
          enable = true;
          window.width = 30;
          closeIfLastWindow = true;
          extraOptions = {
            filesystem = {
              filtered_items = {
                visible = true;
              };
            };
          };
        };

        nix.enable = true;
        nvim-autopairs.enable = true;

        telescope = {
          enable = true;
          settings = {
            pickers.find_files = {
              hidden = true;
            };
          };
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>fb" = "buffers";
            "<leader>fh" = "help_tags";
          };
        };

        tmux-navigator.enable = true;
        rust-tools.enable = true;

        treesitter = {
          enable = true;
          nixvimInjections = true;
          folding = false;
          indent = true;
          nixGrammars = true;
          ensureInstalled = "all";
          incrementalSelection.enable = true;
        };

        treesitter-refactor = {
          enable = true;
        };

        undotree = {
          enable = true;
          settings = {
            FocusOnToggle = true;
            HighlightChangedText = true;
          };
        };
      };


      keymaps = [
        {
          key = "<C-s>";
          action = "<CMD>w<CR>";
          options.desc = "Save";
        }
        {
          key = "<leader>s";
          action = "<CMD>w<CR>";
          options.desc = "Save";
        }
        {
          key = "<leader>q";
          action = "<CMD>q<CR>";
          options.desc = "quit";
        }
        {
          key = "<F2>";
          action = "<CMD>Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          key = "<leader>e";
          action = "<CMD>Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          key = "<leader>fs";
          action = "<CMD>Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          key = "<F3>";
          action = "<CMD>UndotreeToggle<CR>";
          options.desc = "Toggle Undotree";
        }
        {
          key = "<leader>sh";
          action = "<C-w>s";
          options.desc = "Split Horizontal";
        }
        {
          key = "<leader>sv";
          action = "<C-w>v";
          options.desc = "Split Vertical";
        }
        {
          key = "<leader><Left>";
          action = "<C-w>h";
          options.desc = "Select Window Left";
        }
        {
          key = "<leader>h";
          action = "<C-w>h";
          options.desc = "Select Window Left";
        }
        {
          key = "<leader><Right>";
          action = "<C-w>l";
          options.desc = "Select Window Right";
        }
        {
          key = "<leader>l";
          action = "<C-w>l";
          options.desc = "Select Window Right";
        }
        {
          key = "<leader><Down>";
          action = "<C-w>j";
          options.desc = "Select Window Below";
        }
        {
          key = "<leader>j";
          action = "<C-w>j";
          options.desc = "Select Window Below";
        }
        {
          key = "<leader><Up>";
          action = "<C-w>k";
          options.desc = "Select Window Above";
        }
        {
          key = "<leader>k";
          action = "<C-w>k";
          options.desc = "Select Window Above";
        }
        {
          key = "<leader>t";
          action = "<C-w>w";
          options.desc = "Cycle Between Windows";
        }
        {
          key = "<leader>bb";
          action = "<CMD>BufferPick<CR>";
          options.desc = "View Open Buffer";
        }
        {
          key = "<leader>bc";
          action = "<CMD>BufferClose<CR>";
          options.desc = "View Open Buffer";
        }
        {
          key = "<leader>bn";
          action = "<CMD>:bnext<CR>";
          options.desc = "Next Buffer";
        }
        {
          key = "<leader>bp";
          action = "<CMD>:bprev<CR>";
          options.desc = "Previous Buffer";
        }
        {
          mode = "v";
          key = "<";
          action = "<gv";
          options.desc = "Tab Text Right";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
          options.desc = "Tab Text Left";
        }
        {
          mode = "n";
          key = "<C-/>";
          action = "<Plug>(comment_toggle_linewise_current)";
          options.desc = "(Un)comment in Normal Mode";
        }
        {
          mode = "v";
          key = "<C-/>";
          action = "<Plug>(comment_toggle_linewise_visual)";
          options.desc = "(Un)comment in Visual Mode";
        }
        {
          mode = "n";
          key = "<C-S-/>";
          action = "<Plug>(comment_toggle_blockwise_current)";
          options.desc = "(Un)comment in Normal Mode";
        }
        {
          mode = "v";
          key = "<C-S-/>";
          action = "<Plug>(comment_toggle_blockwise_visual)";
          options.desc = "(Un)comment in Visual Mode";
        }
        {
          mode = "n";
          key = "gd";
          action = "<CMD>lua vim.lsp.buf.hover()<CR>";
        }
        {
          mode = "n";
          key = "gD";
          action = "<CMD>lua vim.lsp.buf.definition()<CR>";
        }
        {
          mode = "n";
          key = "ge";
          action = "<CMD>lua vim.diagnostic.open_float()<CR>";
        }
        {
          mode = "n";
          key = "<leader>r";
          action = ":! ";
        }
      ];
    };
  };
}
